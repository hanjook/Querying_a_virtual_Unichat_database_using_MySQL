-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1

SELECT 
Id AS forumID,
Topic,
ClosedBy AS lecturerID
FROM forum
WHERE forum.CreatedBy = forum.ClosedBy;

-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2

SELECT 
lecturer.id AS lecturerID,
CONCAT(user.Firstname, ' ', user.Lastname) AS Fullname,
COUNT(CreatedBy) AS numberofForums
FROM lecturer 
LEFT OUTER JOIN forum ON lecturer.id = forum.CreatedBy
LEFT OUTER JOIN user ON lecturer.id = user.Id
GROUP BY lecturer.id;

-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3

SELECT
Id AS userId,
Username
FROM user
WHERE Id NOT IN 
	(SELECT 
    PostedBy 
    FROM post 
    WHERE forum IS NOT NULL);


-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT
Id
FROM post
LEFT OUTER JOIN likepost ON post.Id = likepost.Post
WHERE Id NOT IN 
	(SELECT 
    ParentPost 
    FROM post 
    WHERE ParentPost IS NOT NULL) -- Get the posts without comments
AND Post IS NULL -- get posts that has no likes
AND forum IS NOT NULL; -- only get the top level post


-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5

SELECT 
Id,
Content,
COUNT(Id) AS numberoflikes
FROM post
LEFT OUTER JOIN likepost ON post.Id = likepost.Post
GROUP BY(Id)
HAVING numberoflikes IN 
	(SELECT 
    MAX(likes) 
	FROM 
		(SELECT 
        COUNT(Post) AS likes 
		FROM likepost 
		GROUP BY Post) AS maxlikes); -- nested Select in order to first get the list of number of likes per post and then get the largest number

-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6

SELECT 
length(Content) AS length,
Content,
Topic,
CONCAT(user.Firstname, ' ', user.Lastname) AS Fullname
FROM post 
INNER JOIN forum ON post.forum = forum.Id
INNER JOIN user ON post.PostedBy = user.Id
WHERE length(Content) IN 
	(SELECT 
    MAX(LENGTH(CONTENT)) 
	FROM post);

-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7

SELECT 
Student1 AS student1ID,
Student2 AS student2ID
FROM friendof
WHERE TIMESTAMPDIFF(day, WhenConfirmed, WhenUnfriended) IN 
	(SELECT 
	MIN(TIMESTAMPDIFF(day, WhenConfirmed, WhenUnfriended)) 
	FROM friendof);

-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8

SELECT 
likepost.User AS UserID,
NoContent - 1 AS OtherLikeCount,
likepost.Post AS postId
FROM likepost
INNER JOIN 
(SELECT 
likepost.Post,
COUNT(likepost.Post) AS NoContent 
FROM likepost
GROUP BY likepost.Post) AS countoflikes ON countoflikes.Post = likepost.Post;

-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9

SELECT
student.Id AS userID
FROM (SELECT
Post, 
COUNT(Post), 
PostedBy
FROM likepost 
INNER JOIN post ON likepost.Post = post.Id
INNER JOIN student ON post.PostedBy = student.Id	-- to ensure that it was posted by a student
GROUP BY Post
ORDER BY COUNT(POST) DESC
LIMIT 1) AS MaxLikesPost
INNER JOIN student AS popularStudent ON MaxLikesPost.PostedBy = popularStudent.Id 	-- This makes a table with only the details of the popular student in it
INNER JOIN friendof ON MaxLikesPost.PostedBy = friendof.Student1 OR MaxLikesPost.PostedBy = friendof.Student2	 -- joins details of potential friends of the popular student
INNER JOIN student ON (student.Id = Student2 OR student.Id = Student1) AND student.Id <> popularStudent.Id	-- joins the extra details (Degree) of the potential friends
WHERE WhenConfirmed IS NOT NULL 	-- check if friend request was confirmed
AND WhenRejected IS NULL 		-- check if friend request was not rejected
AND WhenUnfriended IS NULL		-- check if they are unfriended
AND student.Degree = popularStudent.Degree	-- check if they are in the same Course
GROUP BY student.Id;

-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10

SELECT
post.ID AS postID,
post.WhenPosted
FROM post
INNER JOIN student ON student.Id = post.PostedBy
INNER JOIN 
(SELECT
post.Id
FROM post
WHERE post.Id NOT IN 
	(SELECT 
	Id 
	FROM post
	WHERE forum IS NULL)) AS top_level_posts ON top_level_posts.Id = post.Id -- join the the top_level_posts by students
LEFT OUTER JOIN (SELECT
*
FROM post
WHERE post.Id NOT IN 
	(SELECT 
	Id 
	FROM post 
	WHERE forum IS NOT NULL)) AS top_post_comments ON top_post_comments.ParentPost = post.Id	-- join the comments made on the top_level_posts (but still keeping the top_level_post without comments)
INNER JOIN forum ON post.Forum = forum.id
WHERE top_post_comments.Id IS NULL		-- check if the post is unanswered
OR TIMESTAMPDIFF(HOUR, post.WhenPosted, top_post_comments.WhenPosted) <= 48 	-- Check whether the comment was posted within 48 hours
AND forum.CreatedBy = top_post_comments.Postedby		-- Check if the comment was by the teacher who made the forum
GROUP BY postID;


-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line