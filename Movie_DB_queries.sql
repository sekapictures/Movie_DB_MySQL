#  QUERIES 
# QUERY 1
# List all movies where that have come out within a specified year range. Return movie title, movie’s release year, number of actors
# Let the year range be 1999 - 2009
SELECT Title, Year_Of_release, count(stars_in_actor.FK_Actor_ID) + count(stars_in_director.FK_Director_ID) as Num_Of_Actors
FROM movie
LEFT JOIN stars_in_actor ON stars_in_actor.FK_Movie_ID = Movie.ID
LEFT JOIN stars_in_director ON stars_in_director.FK_Movie_ID = Movie.ID
WHERE (Year_Of_release > 1999 and Year_Of_release < 2009)
GROUP BY Movie.ID
ORDER BY Year_Of_release desc;

# QUERY 2
# List all quotes for selected actor, listing the quote, the movie in which it was said, a year when the movie came out
# This Query will only list actors who have quotes and will skip actors without quotes
# Also in this database it is possible that same quote could be said by different actors in different films (refer to is_said_in)
SELECT First_Name, Last_Name, Quote.Content AS Quote, Movie.Title AS Movie, Movie.Year_Of_release AS 'Year of Release'
FROM actor
RIGHT JOIN is_said_by ON is_said_by.FK_Actor_ID = Actor.id
LEFT JOIN Quote ON is_said_by.FK_Quote_ID = Quote.ID
LEFT JOIN is_said_in ON is_said_in.FK_Quote_ID = Quote.ID AND is_said_in.FK_Actor_ID = Actor.ID
LEFT JOIN movie ON is_said_in.FK_Movie_ID = Movie.ID
ORDER BY First_Name;

# VIEWS, USER-DEFINED FUNCTIONS AMD STORED PROCEDURES
# Let the View name for the first query be AllMoviesAndNumOfActorsWithinYearRange
# VIEW
CREATE VIEW  AllMoviesAndNumOfActorsWithinYearRange AS
SELECT Title, Year_Of_release, count(stars_in_actor.FK_Actor_ID) + count(stars_in_director.FK_Director_ID) as Num_Of_Actors
FROM movie
LEFT JOIN stars_in_actor ON stars_in_actor.FK_Movie_ID = Movie.ID
LEFT JOIN stars_in_director ON stars_in_director.FK_Movie_ID = Movie.ID
WHERE (Year_Of_release > 1999 and Year_Of_release < 2009)
GROUP BY Movie.ID
ORDER BY Year_Of_release desc;

# The View for the first query
SELECT * FROM AllMoviesAndNumOfActorsWithinYearRange;

# USER-DEFINED FUNCTION
# The function calculates the number of actors the first query requires
# It takes Movie ID as input and counts actors accordingly
DELIMITER // 
CREATE FUNCTION CountActors(MID INT) 
	RETURNS INT 
	READS SQL DATA 
	BEGIN 
		RETURN ( SELECT (count(stars_in_actor.FK_Actor_ID) + count(stars_in_director.FK_Director_ID))
		FROM movie
		left JOIN stars_in_actor ON stars_in_actor.FK_Movie_ID = MID
		left JOIN stars_in_director ON stars_in_director.FK_Movie_ID = MID
        WHERE Movie.ID = MID);
	END //
DELIMITER ;

# Function is applied to query as CountActors and counts total cast quantity from actor and possible director roles
SELECT Title, Year_Of_release, CountActors(Movie.ID) AS Num_Of_Actors
FROM movie
WHERE (Year_Of_release > 1999 and Year_Of_release < 2009)
GROUP BY Movie.ID
ORDER BY Year_Of_release desc;

# STORED PROCEDURE
# The stored procedure contains the second query
# List all quotes for selected actor, listing the quote, the movie in which it was said, a year when the movie came out
DELIMITER // 
CREATE PROCEDURE ListActorQuotes () 
BEGIN 
	SELECT First_Name, Last_Name, Quote.Content AS Quote, Movie.Title AS Movie, Movie.Year_Of_release AS 'Year of Release'
	FROM actor
	RIGHT JOIN is_said_by ON is_said_by.FK_Actor_ID = Actor.id
	LEFT JOIN Quote ON is_said_by.FK_Quote_ID = Quote.ID
	LEFT JOIN is_said_in ON is_said_in.FK_Quote_ID = Quote.ID AND is_said_in.FK_Actor_ID = Actor.ID
	LEFT JOIN movie ON is_said_in.FK_Movie_ID = Movie.ID
	ORDER BY First_Name;
END// 
DELIMITER ;

CALL ListActorQuotes();

#  CREATING TABLES

#  INITIAL COMMANDS
SET SQL_SAFE_UPDATES=0;
CREATE DATABASE assignment3_asergeev;

USE assignment3_asergeev;

SHOW TABLES;

CREATE TABLE Movie 
( 
    ID Int NOT NULL auto_increment, 
    Title VARCHAR(100) NOT NULL,
    Year_Of_Release SMALLINT NOT NULL,
    Length_Min SMALLINT NOT NULL,
    Plot_Outline TEXT NOT NULL,
    PRIMARY KEY (ID) 
);

CREATE TABLE Genre
(
	ID Int NOT NULL AUTO_INCREMENT PRIMARY KEY, 
	Genre VARCHAR(30) NOT NULL
);

CREATE TABLE Movie_Genre
(
	FK_Movie_ID Int NOT NULL,
    FK_Genre_ID Int NOT NULL,
    
    FOREIGN KEY (FK_Movie_ID) REFERENCES Movie(ID),
    FOREIGN KEY (FK_Genre_ID) REFERENCES Genre(ID)
);

CREATE TABLE Director
(
    ID Int NOT NULL auto_increment, 
    First_Name VARCHAR(100) NOT NULL,
    Middle_Name VARCHAR(100),
    Last_Name VARCHAR(100) NOT NULL,
    Date_Of_Birth DATE NOT NULL,
    PRIMARY KEY (ID) 
);

CREATE TABLE Quote
(
	ID Int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Content VARCHAR(250) NOT NULL
);

CREATE TABLE Is_Said_In
(
	FK_Movie_ID Int NOT NULL,
    FK_Quote_ID Int NOT NULL,
    FK_Actor_ID Int NOT NULL,
    
    FOREIGN KEY (FK_Movie_ID) REFERENCES Movie(ID),
    FOREIGN KEY (FK_Actor_ID) REFERENCES Actor(ID),
    FOREIGN KEY (FK_Quote_ID) REFERENCES Quote(ID)
);

CREATE TABLE Is_Said_By
(
	FK_Actor_ID Int NOT NULL,
    FK_Quote_ID Int NOT NULL,
    
    FOREIGN KEY (FK_Actor_ID) REFERENCES Actor(ID),
    FOREIGN KEY (FK_Quote_ID) REFERENCES Quote(ID)
);

CREATE TABLE Actor
(
    ID Int NOT NULL auto_increment, 
    First_Name VARCHAR(100) NOT NULL,
    Middle_Name VARCHAR(100),
    Last_Name VARCHAR(100) NOT NULL,
    Date_Of_Birth DATE NOT NULL,
    PRIMARY KEY (ID)
);

CREATE TABLE Stars_In_Actor
(
	ID Int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	FK_Movie_ID Int NOT NULL,
	FK_Actor_ID Int NOT NULL,
    
	FOREIGN KEY (FK_Movie_ID) REFERENCES Movie(ID),
	FOREIGN KEY (FK_Actor_ID) REFERENCES Actor(ID)
);

CREATE TABLE Stars_In_Director
(
	ID Int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	FK_Movie_ID Int NOT NULL,
	FK_Director_ID Int NOT NULL,
    
	FOREIGN KEY (FK_Movie_ID) REFERENCES Movie(ID),
	FOREIGN KEY (FK_Director_ID) REFERENCES Director(ID)
);

CREATE TABLE Directs
(
	ID Int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	FK_Movie_ID Int NOT NULL,
	FK_Director_ID Int NOT NULL,
    
	FOREIGN KEY (FK_Movie_ID) REFERENCES Movie(ID),
	FOREIGN KEY (FK_Director_ID) REFERENCES Director(ID)
);

CREATE TABLE Company_Address
(
	ID Int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	Company_name VARCHAR(100) NOT NULL, 
	Street VARCHAR(100) NOT NULL, 
	State VARCHAR(100) NOT NULL, 
	City VARCHAR(100) NOT NULL, 
	Zip INT UNSIGNED NOT NULL,
	Street_Num MEDIUMINT UNSIGNED
);

CREATE TABLE Production_Company
(
    FK_Company_ID Int NOT NULL,
    FK_Movie_ID Int NOT NULL,
    
    FOREIGN KEY (FK_Company_ID) REFERENCES Company_Address(ID),
    FOREIGN KEY (FK_Movie_ID) REFERENCES Movie(ID)
);

# ADDING DATA TO TABLES
# MOVIE
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (1, 'Profession of Arms, The (Il mestiere delle armi)', 2006, 149, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (2, 'Taste the Blood of Dracula', 2003, 175, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (3, 'Planet of the Apes', 1998, 109, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (4, 'Beach, The', 2010, 17, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (5, 'Holiday, The', 2001, 262, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (6, 'Metalstorm: The Destruction of Jared-Syn', 2004, 26, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (7, 'Battle in Heaven (Batalla en el cielo)', 1993, 173, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (8, 'Little Miss Marker', 2007, 205, 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (9, 'Sweeney Todd: The Demon Barber of Fleet Street', 2005, 66, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (10, 'Broadway Damage', 2000, 60, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (11, '13 Assassins (Jûsan-nin no shikaku)', 2002, 171, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (12, 'Welcome to New York', 1984, 154, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (13, '7 Faces of Dr. Lao', 2000, 33, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (14, 'Blue Lagoon, The', 2003, 165, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (15, 'Proposition, The', 2005, 103, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (16, 'Bay, The', 1992, 213, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (17, 'Virginia', 1995, 275, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (18, 'Studentfesten', 1996, 276, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (19, 'Night Crossing', 2005, 181, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (20, 'Bohemian Life, The (La vie de bohème)', 2010, 87, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (21, 'Blind (Beul-la-in-deu)', 1996, 84, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (22, 'Desert Bloom', 2003, 226, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (23, 'King of Beggars (Mo jong yuen So Hat-Yi)', 1994, 255, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (24, 'Maps to the Stars', 1994, 139, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (25, 'Rough House, The', 2009, 216, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (26, 'I Love You, Don''t Touch Me!', 1980, 206, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (27, 'I Love You, Man', 2009, 270, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (28, 'Claire Dolan', 2010, 233, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (29, 'Gaudi Afternoon', 2005, 107, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (30, 'Light Is Calling', 1984, 93, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (31, 'Marathon Man', 2008, 209, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (32, 'All Quiet on the Western Front', 1994, 130, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (33, 'Pretty Bird', 2011, 92, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (34, 'Humboldt County', 2001, 191, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (35, 'Tarzan Escapes', 2004, 69, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (36, 'Berkeley in the ''60s', 2001, 125, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (37, 'Indiana Jones and the Temple of Doom', 1985, 24, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (38, 'Wadjda', 1993, 40, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (39, 'Lilo & Stitch', 1999, 298, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (40, 'Killing of Sister George, The', 1995, 272, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (41, 'Great Mouse Detective, The', 1986, 44, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (42, 'To Encourage the Others', 1999, 226, 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (43, 'The Hunchback of Paris', 2011, 29, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (44, 'Max Payne', 2007, 224, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (45, 'Death Wish 2', 2001, 266, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (46, 'El Escarabajo de Oro', 1999, 227, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (47, 'Run Ronnie Run', 1998, 176, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (48, 'City Lights', 1984, 64, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (49, '2:13', 2005, 23, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into Movie (id, Title, Year_Of_Release, Length_Min, Plot_Outline) values (50, 'My Mother and Her Guest (Sarangbang sonnimgwa eomeoni)', 2008, 209, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');

# ACTOR
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (1, 'Sherlock', null, 'Lauga', '2019-02-21');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (2, 'Dall', 'zinc cold therapy', 'Moxsom', '1921-04-19');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (3, 'Ailene', 'Inon Ace', 'Dodamead', '1961-07-13');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (4, 'Greg', 'Nabumetone', 'Birmingham', '1970-11-04');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (5, 'Cindy', null, 'Confait', '1961-08-26');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (6, 'Pascal', 'Dye Free Ibuprofen', 'Kaesmans', '1945-10-03');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (7, 'Gisella', 'Preferred Plus Urinary Pain Relief', 'Ruggs', '2010-12-31');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (8, 'Tye', 'Tineacide', 'Yakunikov', '1928-09-01');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (9, 'Sara', 'Paricalcitol', 'Kemmis', '1965-08-18');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (10, 'Duke', null, 'Ten Broek', '1931-05-09');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (11, 'Nydia', null, 'Furlonge', '1967-07-28');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (12, 'Natale', 'Azithromycin', 'Cleveland', '1922-10-09');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (13, 'Chip', 'ORRIS ROOT', 'Ellcock', '1944-11-20');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (14, 'Liz', 'Avon Elements', 'Smalles', '1921-02-19');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (15, 'Gardener', 'LE TECHNIQ', 'Rollitt', '2009-11-30');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (16, 'Francisca', 'More Than Moisture SPF 30', 'Tague', '2018-06-13');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (17, 'Mile', 'Pain and Fever', 'Matfield', '1926-11-29');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (18, 'Hartwell', 'PROMETHAZINE DM', 'Antczak', '2010-08-28');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (19, 'Dion', 'Oxybutynin Chloride', 'Davidove', '1951-01-05');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (20, 'Clyve', null, 'Blower', '1941-04-02');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (21, 'Pandora', 'BABOR Cleansing Mild Peeling', 'Scamerdine', '1941-03-30');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (22, 'Dalli', 'Coffee', 'Kliemke', '2005-11-10');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (23, 'Willa', 'Shellfish and Seafood Allergy Relief', 'Pickrell', '1951-10-27');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (24, 'Pammi', null, 'Osgodby', '1997-09-28');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (25, 'Mary', 'Cabergoline', 'Ramel', '1980-05-11');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (26, 'Kerwinn', 'Dutoprol', 'Moncreif', '1930-12-21');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (27, 'Cesya', 'Fludarabine Phosphate', 'Commusso', '1931-09-05');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (28, 'Lothaire', 'AIR COMPRESSED', 'Giraudo', '2012-12-20');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (29, 'Coletta', 'Sweet Fig Antibacterial Foaming Hand Wash', 'Kull', '2005-12-10');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (30, 'Burlie', 'Pleo Citro', 'Schapiro', '1988-03-25');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (31, 'Conway', 'HEALTHCARE Instant Hand Sanitizer Strawberry Scent', 'Asbery', '1924-10-23');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (32, 'Cecily', null, 'Sandars', '2009-11-03');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (33, 'Doy', 'Pravastatin Sodium', 'Mardee', '1983-06-28');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (34, 'Kerwin', null, 'Larwell', '2018-08-09');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (35, 'Jarad', 'Ulta Sparkling Lemon Anti-Bacterial Deep Cleansing', 'Kacheller', '2009-08-30');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (36, 'Eugenie', 'Losartan Potassium', 'Taylorson', '1951-12-26');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (37, 'Manny', null, 'Playfoot', '1982-10-08');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (38, 'Grover', null, 'De Witt', '1929-07-06');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (39, 'Clem', 'Amiodarone Hydrochloride', 'Kenewell', '1992-04-22');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (40, 'Ardath', null, 'Lansberry', '1973-03-16');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (41, 'Kikelia', null, 'Corwood', '1921-11-25');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (42, 'Ronny', 'Gas-X', 'Thorby', '2004-04-30');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (43, 'Alexine', 'Mozobil', 'Kemell', '2003-03-13');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (44, 'Bess', 'Simply Firm - Body', 'Arter', '1961-12-06');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (45, 'Scarface', 'Gabapentin', 'Foyster', '2019-01-19');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (46, 'Gertie', 'LIPIODOL', 'Laurance', '1953-05-27');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (47, 'Candice', 'berkley and jensen nicotine polacrilex', 'Samworth', '1981-11-08');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (48, 'Zarah', 'AMOREPACIFIC', 'Gibbings', '2010-02-06');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (49, 'Meagan', 'pain relief', 'Eustes', '2019-01-02');
insert into Actor (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (50, 'Shelly', 'PONDS', 'Ledner', '1984-04-12');

# ACTOR STARS IN MOVIES
insert into stars_in_actor values (1, 37, 6);
insert into stars_in_actor values (2, 18, 16);
insert into stars_in_actor values (3, 37, 3);
insert into stars_in_actor values (4, 7, 5);
insert into stars_in_actor values (5, 42, 10);
insert into stars_in_actor values (6, 14, 38);
insert into stars_in_actor values (7, 11, 26);
insert into stars_in_actor values (8, 11, 39);
insert into stars_in_actor values (9, 25, 43);
insert into stars_in_actor values (10, 44, 44);
insert into stars_in_actor values (11, 36, 1);
insert into stars_in_actor values (12, 29, 36);
insert into stars_in_actor values (13, 1, 2);
insert into stars_in_actor values (14, 14, 2);
insert into stars_in_actor values (15, 37, 31);
insert into stars_in_actor values (16, 49, 31);
insert into stars_in_actor values (17, 38, 16);
insert into stars_in_actor values (18, 43, 38);
insert into stars_in_actor values (19, 21, 49);
insert into stars_in_actor values (20, 1, 10);

# DIRECTOR
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (1, 'Ericka', 'Povidone-Iodine Scrub Swabsticks', 'Korba', '1983-06-15');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (2, 'Gizela', 'Olanzapine', 'Desbrow', '2002-01-15');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (3, 'Stirling', null, 'Matiebe', '1982-09-22');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (4, 'Carine', null, 'Langlands', '2017-05-26');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (5, 'Ofilia', 'Imiquimod', 'Myrkus', '1996-01-18');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (6, 'Ag', null, 'Charnock', '1929-11-03');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (7, 'Lesli', 'LEVOPHED', 'Rawlin', '1990-12-28');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (8, 'Gabbi', 'Diaper Rash', 'Goose', '1983-02-13');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (9, 'Drusi', 'Vitamin K1', 'Strowther', '1992-01-19');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (10, 'Moore', null, 'Bartel', '2011-08-30');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (11, 'Javier', null, 'O''Connor', '1956-11-15');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (12, 'Marcia', null, 'Bentick', '1977-11-22');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (13, 'Douglas', 'Ramipril', 'Minchin', '1930-10-24');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (14, 'Broddie', 'AMERFRESH ROLL-ON ANTIPERSPIRANT DEODORANT', 'Lammers', '2008-04-24');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (15, 'Claudelle', 'Naturasil', 'Duesbury', '1945-01-18');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (16, 'Silva', null, 'Dymick', '2004-09-21');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (17, 'Rheta', 'Penicillin V Potassium', 'Ludlamme', '1979-11-29');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (18, 'Liuka', null, 'Vallintine', '2019-06-19');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (19, 'Gardiner', 'Trazodone Hydrochloride', 'Longthorn', '1991-04-24');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (20, 'Dolores', null, 'Murrhardt', '1935-12-13');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (21, 'Reese', 'Rough Pigweed', 'Shaefer', '1938-08-18');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (22, 'Egan', 'Cerebroforce', 'Dobkin', '1977-09-10');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (23, 'Georgeanne', 'Market Basket Cold Sore Treatment', 'Derks', '2009-07-18');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (24, 'Charles', 'Hepar Stannum 6/10', 'Jenno', '1949-01-13');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (25, 'Raimundo', 'Sole', 'Kinnar', '2021-05-19');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (26, 'Verla', 'Anti-Bacterial Hand Gel Pink Lemonade', 'Christer', '1933-04-03');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (27, 'Laverne', 'Dial Complete Antibacterial Foaming Hand Washkitchen crisp limkitchen crisp lim', 'Jizhaki', '1935-08-15');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (28, 'Yorker', 'Tamoxifen Citrate', 'Puddefoot', '1945-03-16');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (29, 'Sioux', 'Dimenhydrinate', 'McIndoe', '2013-06-04');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (30, 'Arlen', 'Risperidone', 'Erett', '1966-12-12');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (31, 'Shayla', 'Kogenate FS', 'Cohr', '1927-06-15');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (32, 'Beckie', null, 'Tanguy', '1987-03-06');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (33, 'Jaclyn', 'Hypothalamus HP', 'Buckner', '1950-07-13');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (34, 'Benjy', 'Epifoam', 'Kuhwald', '2001-12-26');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (35, 'Bliss', 'Leader Mucus Relief', 'Billson', '1939-10-04');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (36, 'Mannie', 'JAKAFI', 'Vousden', '1937-12-04');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (37, 'Sinclare', null, 'Rearden', '1992-04-02');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (38, 'Patrice', 'Bitternut Hickory', 'Brussell', '1923-09-07');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (39, 'Otis', 'Cold and Flu Relief', 'Jandl', '2003-10-03');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (40, 'Nata', null, 'Kield', '2012-05-03');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (41, 'Ranice', 'ckone waterfresh face make up SPF 15', 'Skala', '1935-05-08');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (42, 'Minette', 'Leg Cramp Complex', 'Danett', '1983-04-13');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (43, 'Jeannine', 'Nite Time Cold and Cough', 'Inseal', '2002-08-27');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (44, 'Phip', 'BENZOYL PEROXIDE', 'Spadelli', '1983-04-08');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (45, 'Rennie', null, 'Woodburn', '1938-08-15');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (46, 'Row', null, 'Riguard', '1966-12-07');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (47, 'Luisa', 'Cold and Flu', 'Sieghart', '1942-08-13');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (48, 'Vidovic', null, 'Prosser', '1944-03-07');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (49, 'Wilona', 'GOAT MILK', 'Filipiak', '2015-04-18');
insert into Director (id, First_Name, Middle_Name, Last_Name, Date_Of_Birth) values (50, 'Barth', null, 'Jeffcoate', '1923-10-03');

# DIRECTOR DIRECTS
insert into directs values (1, 23, 7);
insert into directs values (2, 25, 43);
insert into directs values (3, 30, 6);
insert into directs values (4, 24, 44);
insert into directs values (5, 43, 26);
insert into directs values (6, 45, 23);
insert into directs values (7, 46, 40);
insert into directs values (8, 18, 3);
insert into directs values (9, 48, 49);
insert into directs values (10, 29, 7);
insert into directs values (11, 38, 26);
insert into directs values (12, 9, 25);
insert into directs values (13, 11, 29);
insert into directs values (14, 38, 15);
insert into directs values (15, 43, 2);
insert into directs values (16, 22, 43);
insert into directs values (17, 23, 49);
insert into directs values (18, 38, 3);
insert into directs values (19, 38, 26);
insert into directs values (20, 38, 1);

# DIRECTOR STARS IN MOVIES
insert into stars_in_director values (1, 43, 27);
insert into stars_in_director values (2, 2, 10);
insert into stars_in_director values (3, 3, 8);
insert into stars_in_director values (4, 16, 1);
insert into stars_in_director values (5, 37, 25);
insert into stars_in_director values (6, 28, 32);
insert into stars_in_director values (7, 32, 41);
insert into stars_in_director values (8, 23, 12);
insert into stars_in_director values (9, 42, 18);
insert into stars_in_director values (10, 44, 46);
insert into stars_in_director values (11, 39, 40);
insert into stars_in_director values (12, 10, 40);
insert into stars_in_director values (13, 46, 34);
insert into stars_in_director values (14, 21, 11);
insert into stars_in_director values (15, 50, 17);
insert into stars_in_director values (16, 50, 28);
insert into stars_in_director values (17, 49, 10);
insert into stars_in_director values (18, 25, 6);
insert into stars_in_director values (19, 14, 5);
insert into stars_in_director values (20, 22, 46);

# GENRE
insert into Genre (id, genre) values (1, 'Action');
insert into Genre (id, genre) values (2, 'Comedy');
insert into Genre (id, genre) values (3, 'Drama');
insert into Genre (id, genre) values (4, 'Fantasy');
insert into Genre (id, genre) values (5, 'Horror');
insert into Genre (id, genre) values (6, 'Myster');
insert into Genre (id, genre) values (7, 'Romance');
insert into Genre (id, genre) values (8, 'Thriller');
insert into Genre (id, genre) values (9, 'Western');

# COMPANY
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (1, 'Layo', 'Montana', 'Nevada', 'Las Vegas', 69811, '832');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (2, 'Ailane', 'Karstens', 'Pennsylvania', 'Pittsburgh', 58141, '95589');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (3, 'Eidel', 'Dunning', 'Georgia', 'Atlanta', 60373, '6');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (4, 'Brightbean', 'Emmet', 'Colorado', 'Colorado Springs', 27525, '033');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (5, 'Twiyo', 'Schlimgen', 'District of Columbia', 'Washington', 78167, '2379');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (6, 'Divavu', 'Brentwood', 'Idaho', 'Idaho Falls', 71971, '38090');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (7, 'Mita', 'Green', 'Illinois', 'Chicago', 79133, '518');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (8, 'Dabshots', 'Sommers', 'New Mexico', 'Albuquerque', 52095, '3209');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (9, 'Thoughtblab', 'Fulton', 'Florida', 'West Palm Beach', 33781, '4078');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (10, 'Quire', 'David', 'Michigan', 'Lansing', 57872, '8863');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (11, 'Divavu', 'Riverside', 'Virginia', 'Richmond', 91183, '115');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (12, 'Fliptune', 'Straubel', 'Florida', 'Sarasota', 62057, '604');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (13, 'Oodoo', 'Messerschmidt', 'California', 'San Diego', 26645, '3613');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (14, 'Aimbu', 'Grover', 'California', 'San Diego', 43268, '8302');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (15, 'Youtags', 'Lotheville', 'Florida', 'Naples', 72284, '91714');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (16, 'Riffwire', 'Monica', 'Illinois', 'Chicago', 36096, '596');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (17, 'Blogspan', 'Anthes', 'California', 'Northridge', 33277, '49');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (18, 'Oyoba', 'Jenifer', 'California', 'Whittier', 93302, '93');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (19, 'Edgeblab', 'Dovetail', 'District of Columbia', 'Washington', 64170, '54939');
insert into Company_Address (id, Company_name, Street, State, City, Zip, Street_Num) values (20, 'Centidel', 'Clemons', 'California', 'Corona', 19275, '8297');

# QUOTE
insert into Quote (id, Content) values (1, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into Quote (id, Content) values (2, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into Quote (id, Content) values (3, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into Quote (id, Content) values (4, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into Quote (id, Content) values (5, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into Quote (id, Content) values (6, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into Quote (id, Content) values (7, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into Quote (id, Content) values (8, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into Quote (id, Content) values (9, 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into Quote (id, Content) values (10, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into Quote (id, Content) values (11, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into Quote (id, Content) values (12, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into Quote (id, Content) values (13, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.');
insert into Quote (id, Content) values (14, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into Quote (id, Content) values (15, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into Quote (id, Content) values (16, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into Quote (id, Content) values (17, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into Quote (id, Content) values (18, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into Quote (id, Content) values (19, 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into Quote (id, Content) values (20, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');

# QUOTE RELATED TO ACTOR
insert into Is_Said_By values (44, 14);
insert into Is_Said_By values (27, 17);
insert into Is_Said_By values (4, 15);
insert into Is_Said_By values (34, 6);
insert into Is_Said_By values (5, 4);
insert into Is_Said_By values (18, 7);
insert into Is_Said_By values (7, 17);
insert into Is_Said_By values (50, 8);
insert into Is_Said_By values (29, 3);
insert into Is_Said_By values (18, 2);
delete from Is_Said_By;
delete from Is_Said_by;
delete from Is_Said_in;
# QUOTE RELATED TO MOVIE
insert into Is_Said_In values (43, 14, 44);
insert into Is_Said_In values (28, 17, 27);
insert into Is_Said_In values (14, 15, 4);
insert into Is_Said_In values (35, 6, 34);
insert into Is_Said_In values (45, 4, 5);
insert into Is_Said_In values (19, 7, 18);
insert into Is_Said_In values (17, 17, 7);
insert into Is_Said_In values (30, 8, 50);
insert into Is_Said_In values (21, 3, 29);
insert into Is_Said_In values (10, 2, 18);

# GENRE RELATED TO MOVIE
insert into movie_genre values (16, 8);
insert into movie_genre  values (38, 9);
insert into movie_genre  values (3, 1);
insert into movie_genre  values (49, 6);
insert into movie_genre  values (8, 9);
insert into movie_genre  values (7, 6);
insert into movie_genre  values (8, 3);
insert into movie_genre  values (2, 8);
insert into movie_genre  values (36, 2);
insert into movie_genre  values (25, 7);
insert into movie_genre  values (17, 6);
insert into movie_genre  values (40, 8);
insert into movie_genre  values (46, 6);
insert into movie_genre  values (40, 2);
insert into movie_genre  values (18, 7);
insert into movie_genre  values (28, 4);
insert into movie_genre  values (36, 9);
insert into movie_genre  values (7, 8);
insert into movie_genre  values (35, 3);
insert into movie_genre  values (43, 7);
insert into movie_genre  values (32, 6);
insert into movie_genre  values (10, 3);
insert into movie_genre  values (9, 3);
insert into movie_genre  values (14, 8);
insert into movie_genre  values (20, 7);
insert into movie_genre  values (24, 2);
insert into movie_genre  values (45, 2);
insert into movie_genre  values (27, 8);
insert into movie_genre  values (2, 8);
insert into movie_genre  values (11, 8);
insert into movie_genre  values (49, 8);
insert into movie_genre  values (21, 3);
insert into movie_genre  values (3, 2);
insert into movie_genre  values (43, 6);
insert into movie_genre  values (47, 2);
insert into movie_genre  values (46, 4);
insert into movie_genre  values (1, 6);
insert into movie_genre  values (42, 5);
insert into movie_genre  values (39, 2);
insert into movie_genre  values (25, 4);
insert into movie_genre  values (34, 9);
insert into movie_genre  values (10, 1);
insert into movie_genre  values (25, 6);
insert into movie_genre  values (2, 1);
insert into movie_genre  values (30, 9);
insert into movie_genre  values (27, 5);
