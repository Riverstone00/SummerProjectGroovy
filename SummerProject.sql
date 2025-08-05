CREATE TABLE `Like` (
	`UserID`	varchar(30)	NOT NULL,
	`PostID`	varchar(20)	NOT NULL,
	`Key`	VARCHAR(255)	NOT NULL
);

CREATE TABLE `Review` (
	`UserID`	varchar(30)	NOT NULL,
	`PostID`	varchar(20)	NOT NULL,
	`UserID2`	varchar(30)	NOT NULL,
	`Key`	VARCHAR(255)	NOT NULL,
	`Rating`	number	NOT NULL	DEFAULT 10
);

CREATE TABLE `Image` (
	`ImageURL`	varchar	NOT NULL,
	`PostID`	varchar(20)	NOT NULL,
	`Key`	VARCHAR(255)	NOT NULL,
	`UserID`	varchar(30)	NOT NULL
);

CREATE TABLE `Course` (
	`PostID`	varchar(20)	NOT NULL,
	`Key`	VARCHAR(255)	NOT NULL,
	`UserID`	varchar(30)	NOT NULL,
	`Title`	varchar(20)	NOT NULL,
	`Likes`	number	NOT NULL	DEFAULT 0,
	`TimeEstimated`	time	NOT NULL,
	`PlaceOrder`	list<Place>	NOT NULL
);

CREATE TABLE `Hashtag` (
	`TagName`	varchar(20)	NOT NULL,
	`PostID`	varchar(20)	NOT NULL,
	`Key`	VARCHAR(255)	NOT NULL
);

CREATE TABLE `Bookmark` (
	`UserID`	varchar(30)	NOT NULL,
	`PostID`	varchar(20)	NOT NULL,
	`Key`	VARCHAR(255)	NOT NULL
);

CREATE TABLE `Place` (
	`PostID`	varchar(20)	NOT NULL,
	`Key`	VARCHAR(255)	NOT NULL,
	`name`	varchar(20)	NOT NULL,
	`Time`	time	NOT NULL,
	`viewcount`	int	NOT NULL
);

CREATE TABLE `User` (
	`UserID`	varchar(30)	NOT NULL,
	`UserName`	varchar(20)	NULL,
	`isStudent`	bool	NULL	DEFAULT false
);

ALTER TABLE `Like` ADD CONSTRAINT `PK_LIKE` PRIMARY KEY (
	`UserID`,
	`PostID`,
	`Key`
);

ALTER TABLE `Review` ADD CONSTRAINT `PK_REVIEW` PRIMARY KEY (
	`UserID`,
	`PostID`,
	`UserID2`,
	`Key`
);

ALTER TABLE `Image` ADD CONSTRAINT `PK_IMAGE` PRIMARY KEY (
	`ImageURL`,
	`PostID`,
	`Key`,
	`UserID`
);

ALTER TABLE `Course` ADD CONSTRAINT `PK_COURSE` PRIMARY KEY (
	`PostID`,
	`Key`,
	`UserID`
);

ALTER TABLE `Hashtag` ADD CONSTRAINT `PK_HASHTAG` PRIMARY KEY (
	`TagName`,
	`PostID`,
	`Key`
);

ALTER TABLE `Bookmark` ADD CONSTRAINT `PK_BOOKMARK` PRIMARY KEY (
	`UserID`,
	`PostID`,
	`Key`
);

ALTER TABLE `Place` ADD CONSTRAINT `PK_PLACE` PRIMARY KEY (
	`PostID`,
	`Key`
);

ALTER TABLE `User` ADD CONSTRAINT `PK_USER` PRIMARY KEY (
	`UserID`
);

ALTER TABLE `Like` ADD CONSTRAINT `FK_User_TO_Like_1` FOREIGN KEY (
	`UserID`
)
REFERENCES `User` (
	`UserID`
);

ALTER TABLE `Like` ADD CONSTRAINT `FK_Course_TO_Like_1` FOREIGN KEY (
	`PostID`
)
REFERENCES `Course` (
	`PostID`
);

ALTER TABLE `Like` ADD CONSTRAINT `FK_Course_TO_Like_2` FOREIGN KEY (
	`Key`
)
REFERENCES `Course` (
	`Key`
);

ALTER TABLE `Review` ADD CONSTRAINT `FK_User_TO_Review_1` FOREIGN KEY (
	`UserID`
)
REFERENCES `User` (
	`UserID`
);

ALTER TABLE `Review` ADD CONSTRAINT `FK_Course_TO_Review_1` FOREIGN KEY (
	`PostID`
)
REFERENCES `Course` (
	`PostID`
);

ALTER TABLE `Review` ADD CONSTRAINT `FK_Course_TO_Review_2` FOREIGN KEY (
	`UserID2`
)
REFERENCES `Course` (
	`UserID`
);

ALTER TABLE `Review` ADD CONSTRAINT `FK_Course_TO_Review_3` FOREIGN KEY (
	`Key`
)
REFERENCES `Course` (
	`Key`
);

ALTER TABLE `Image` ADD CONSTRAINT `FK_Course_TO_Image_1` FOREIGN KEY (
	`PostID`
)
REFERENCES `Course` (
	`PostID`
);

ALTER TABLE `Image` ADD CONSTRAINT `FK_Course_TO_Image_2` FOREIGN KEY (
	`Key`
)
REFERENCES `Course` (
	`Key`
);

ALTER TABLE `Image` ADD CONSTRAINT `FK_Course_TO_Image_3` FOREIGN KEY (
	`UserID`
)
REFERENCES `Course` (
	`UserID`
);

ALTER TABLE `Course` ADD CONSTRAINT `FK_User_TO_Course_1` FOREIGN KEY (
	`UserID`
)
REFERENCES `User` (
	`UserID`
);

ALTER TABLE `Hashtag` ADD CONSTRAINT `FK_Course_TO_Hashtag_1` FOREIGN KEY (
	`PostID`
)
REFERENCES `Course` (
	`PostID`
);

ALTER TABLE `Hashtag` ADD CONSTRAINT `FK_Course_TO_Hashtag_2` FOREIGN KEY (
	`Key`
)
REFERENCES `Course` (
	`Key`
);

ALTER TABLE `Bookmark` ADD CONSTRAINT `FK_User_TO_Bookmark_1` FOREIGN KEY (
	`UserID`
)
REFERENCES `User` (
	`UserID`
);

ALTER TABLE `Bookmark` ADD CONSTRAINT `FK_Course_TO_Bookmark_1` FOREIGN KEY (
	`PostID`
)
REFERENCES `Course` (
	`PostID`
);

ALTER TABLE `Bookmark` ADD CONSTRAINT `FK_Course_TO_Bookmark_2` FOREIGN KEY (
	`Key`
)
REFERENCES `Course` (
	`Key`
);

ALTER TABLE `Place` ADD CONSTRAINT `FK_Course_TO_Place_1` FOREIGN KEY (
	`PostID`
)
REFERENCES `Course` (
	`PostID`
);

ALTER TABLE `Place` ADD CONSTRAINT `FK_Course_TO_Place_2` FOREIGN KEY (
	`Key`
)
REFERENCES `Course` (
	`Key`
);

