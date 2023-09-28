--Creating a table for the Library database design 

CREATE TABLE Member (
    MemberID INT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Address VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    EmailAddress VARCHAR(50),
    TelephoneNumber VARCHAR(20),
    Username VARCHAR(20) NOT NULL,
    Password VARCHAR(20) NOT NULL,
    MembershipStartDate DATE NOT NULL,
    MembershipEndDate DATE NOT NULL,
    CONSTRAINT CK_Member_DateOfBirth CHECK (DateOfBirth <= GETDATE()),
    CONSTRAINT CK_Member_MembershipEndDate CHECK (MembershipEndDate >= MembershipStartDate)
);
--Create Repayment table

CREATE TABLE Repayment (
    RepaymentID INT PRIMARY KEY,
    MemberID INT NOT NULL,
    RepaymentDate DATE NOT NULL,
    RepaymentTime TIME NOT NULL,
    AmountRepaid FLOAT NOT NULL,
    RepaymentMethodID INT NOT NULL,
    CONSTRAINT FK_Repayment_Member FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    CONSTRAINT FK_Repayment_RepaymentMethod FOREIGN KEY (RepaymentMethodID) REFERENCES RepaymentMethod(RepaymentMethodID),
    CONSTRAINT CK_Repayment_AmountRepaid CHECK (AmountRepaid >= 0)
);



CREATE TABLE RepaymentMethod (
    RepaymentMethodID INT PRIMARY KEY,
    RepaymentMethodName VARCHAR(20) NOT NULL
);


--create Items Table

CREATE TABLE Item (
    ItemID INT PRIMARY KEY,
    ItemTitle VARCHAR(50) NOT NULL,
    ItemTypeID INT NOT NULL,
    Author VARCHAR(50),
    YearOfPublication INT NOT NULL,
    DateAddedToCollection DATE NOT NULL,
    CurrentStatusID INT NOT NULL,
    DateIdentifiedAsLostOrRemoved DATE,
    ISBN VARCHAR(20),
    CONSTRAINT FK_Item_ItemType FOREIGN KEY (ItemTypeID) REFERENCES ItemType(ItemTypeID),
    CONSTRAINT FK_Item_ItemStatus FOREIGN KEY (CurrentStatusID) REFERENCES ItemStatus(ItemStatusID),
    CONSTRAINT CK_Item_YearOfPublication CHECK (YearOfPublication <= YEAR(GETDATE())),
    CONSTRAINT CK_Item_DateAddedToCollection CHECK (DateAddedToCollection <= GETDATE())
);

CREATE TABLE ItemType (
    ItemTypeID INT PRIMARY KEY,
    ItemTypeName VARCHAR(20) NOT NULL
);

CREATE TABLE ItemStatus (
    ItemStatusID INT PRIMARY KEY,
    ItemStatusName VARCHAR(20) NOT NULL
);

--Create loan table

CREATE TABLE Loan (
    LoanID INT PRIMARY KEY,
    MemberID INT NOT NULL,
    ItemID INT NOT NULL,
    LoanDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    LoanStatusID INT NOT NULL,
    CONSTRAINT FK_Loan_Member FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    CONSTRAINT FK_Loan_Item FOREIGN KEY (ItemID) REFERENCES Item(ItemID),
    CONSTRAINT FK_Loan_LoanStatus FOREIGN KEY (LoanStatusID) REFERENCES LoanStatus(LoanStatusID),
    CONSTRAINT CK_Loan_LoanDate CHECK (LoanDate <= GETDATE()),
    CONSTRAINT CK_Loan_DueDate CHECK (DueDate >= LoanDate),
    CONSTRAINT CK_Loan_ReturnDate CHECK (ReturnDate >= LoanDate OR ReturnDate IS NULL)
);

CREATE TABLE LoanStatus (
    LoanStatusID INT PRIMARY KEY,
    LoanStatusName VARCHAR(20) NOT NULL
);



-----Creating a store procedures and user defined functions

CREATE PROCEDURE  SearchByItemTitle
	 @searchString varchar(50)
AS
BEGIN
    SELECT *
    FROM Item
    WHERE [ItemTitle] LIKE '%' + @searchString + '%'
    ORDER BY [YearOfPublication] DESC
END

----- A procedure that returns list of items on loan which have a due date of less than five days from the current date

CREATE FUNCTION GetOnloanItems()
RETURNS TABLE
AS RETURN
(
    SELECT *
    FROM Loan
    WHERE [LoanStatusID] = 1 -- On Loan
        AND [DueDate] <= DATEADD(day, 5, GETDATE())
);

--Insert a new member into database

CREATE PROCEDURE InsertNewMember
    @fullName varchar(50),
    @address varchar(100),
    @dob date,
    @email varchar(50) = NULL,
    @telephone varchar(20) = NULL,
    @username varchar(50),
    @password varchar(50),
    @startDate date,
    @endDate date
AS
BEGIN
    INSERT INTO Member ([FullName], Address, [DateOfBirth], [EmailAddress], [TelephoneNumber],
	Username, Password, [MembershipStartDate], [MembershipEndDate])
    VALUES (@fullName, @address, @dob, @email, @telephone, @username, @password, @startDate, @endDate)
END

---Update the details for an existing member

CREATE PROCEDURE UpdateMemberDetails
    @memberID int,
    @fullName varchar(50),
    @address varchar(100),
    @dob date,
    @email varchar(50) = NULL,
    @telephone varchar(20) = NULL,
    @username varchar(50),
    @password varchar(50),
    @startDate date,
    @endDate date
AS
BEGIN
    UPDATE Member
    SET [FullName] = @fullName,
        Address = @address,
        [DateOfBirth] = @dob,
        [EmailAddress] = @email,
        [TelephoneNumber] = @telephone,
        Username = @username,
        Password = @password,
        [MembershipStartDate] = @startDate,
        [MembershipEndDate] = @endDate
    WHERE [MemberID] = @memberID
END


---Create loan view history

Go
CREATE VIEW LoanHistory  AS
SELECT 
    Loan.[LoanID],
    Member.[FullName] AS [Borrower name],
    Item.[ItemTitle] AS [Borrowed item],
    Loan.[LoanDate],
    Loan.[DueDate],
    Loan.[ReturnDate],
    Item.[CurrentStatusID],
    CASE 
        WHEN Loan.[ReturnDate] IS NOT NULL AND Loan.[ReturnDate] > Loan.[DueDate] 
		THEN DATEDIFF(DAY, Loan.[DueDate], Loan.[ReturnDate]) * 10.0
        ELSE 0
    END AS [FineAmount]
FROM 
    Loan
    JOIN Member ON Loan.[MemberID] = Member.[MemberID]
    JOIN Item ON Loan.[ItemID] = Item.[ItemID];

---Create a trigger to update item when returned------

	CREATE TRIGGER ItemStatusUpdateUponReturn
ON Loan
AFTER UPDATE
AS
BEGIN
    IF UPDATE(ReturnDate)
    BEGIN
        UPDATE Item
        SET CurrentstatusID = 3 -- 3 represents "Available"
        FROM Item
        INNER JOIN inserted ON Item.[ItemID] = inserted.[ItemID]
        WHERE inserted.[Returndate] IS NOT NULL
    END
END



---- Total number of loans made on a specified date.

SELECT COUNT(*) AS [Total Loans]
FROM Loan
WHERE [Loandate] = '2023-03-15'

---- Insert dummy data into Member ID--------

INSERT INTO Member (MemberID, FullName, Address, DateOfBirth, EmailAddress, TelephoneNumber, Username, Password, MembershipStartDate, MembershipEndDate)
VALUES (0001, 'Yinka Sunmola', '3 Orelusi Street, Ayegun, Manchester', '1998-05-23', 'yinks067@gmail.com', '08054569', 'yinks', '12345', '2023-09-15', '2025-09-15'),
       (0002, 'Abiodn Raji', '32 Bowers Street, Kent, Manchester', '1989-09-15', 'abiodunraj@gmail.com', '080995694', 'Raajii', '9898', '2023-08-14', '2023-08-15'),
       (0003, 'Sam Edwin', '93 Ligali Street, Kent, Machester', '1989-09-15', 'Sam1@gmail.com', '080 977 5694', 'Edinajo', '9898', '2023-08-14', '2024-06-15'),
	    (0004, 'Ewenu Alberta', '42 moore Street, Adelaide, Manchester', '1996-04-13', 'Fijio@gmail.com', '080 564 568 59', 'Simpli10', '2398', '2023-08-14', '2024-06-15'),
		 (0005, 'Ibraheem Baballa', '24 Goodmans Street, Kent, Manchester', '1976-09-15', 'Babs1@gmail.com', '0809 4646 74', 'B111', '9876', '2024-08-14', '2025-06-15');


-- Inserting ramdom data into Itemtype
INSERT INTO ItemType (ItemTypeID, ItemTypeName)
VALUES (1, 'Book'), (2, 'Journal'), (3,'DVD'), (4,'Other Media');

-- Inserting ramdom data into ItemStatus
INSERT INTO ItemStatus (ItemStatusID, ItemStatusName)
VALUES (1,'On Loan'),
       (2, 'Overdue'),
       (3, 'Available'),
       (4, 'Lost/Removed');

-- Inserting random data into loan table
INSERT INTO LoanStatus (LoanStatusID, LoanStatusName )
VALUES (1, 'On Loan'),
       (2, 'Overdue'),
       (3, 'Returned')

-- Inserting ramdom data into Item table
INSERT INTO Item (ItemID, ItemTitle, ItemTypeID, Author, YearOfPublication, DateAddedToCollection, CurrentStatusID, ISBN)
VALUES
(1, 'Te Infamous Bandero', 1, 'D. Spencer', 1993, '2022-08-11', 1, '0316776766'),
(2, 'The Aparthied', 1, 'Greg Mulumba', 1968, '2022-04-24', 1, '1234564444'),
(3, 'Free Palestine', 1, 'Yasir Arafat', 2000, '2022-06-11', 1, '978074357865'),
(4, 'Aroung the world', 1, 'Sinera Josh', 1988, '2022-04-07', 2, '978044451524935'),
(5, '1 day war', 2, 'Hosni Jew', 1954, '1964-01-05', 4, '97805479248203'),
(6, 'Mufasa', 2, 'Lion King', 1997, '2022-04-06', 1, '97807475345443');


-- Inserting random data into Item table
INSERT INTO Loan (LoanID, MemberID, ItemID, Loandate, Duedate, Returndate, LoanStatusID)
VALUES (0,1, 1, '2022-03-01', '2022-03-15', NULL, 1),
       (1,2, 2, '2022-03-02', '2022-03-10', NULL, 1),
       (2,3, 3, '2022-03-03', '2022-03-17', NULL, 1),
       (3,1, 4, '2022-03-04', '2022-03-18', NULL, 1),
       (4,2, 5, '2022-03-05', '2022-03-19', NULL, 1);



-- Insert sample data into Overdue fines table
INSERT INTO (OverdueFines), (MemberID), (TotalOverdueFines)
VALUES (1, 5.50),
       (2, 0.75),
       (3, 2.25);

SELECT * FROM Repayment;

DELETE FROM loan WHERE LoanID = 0;






--Testing  if the select function is working well
SELECT * FROM [Loan];

--Testing the user defined function LoanHistory----
SELECT * FROM [LoanHistory];


--Testing the stored procedures----
INSERT INTO Item (ItemID, ItemTitle, ItemTypeID, Author, YearOfPublication, DateAddedToCollection, CurrentStatusID, ISBN)
VALUES
(7, 'Mr Goldfinger Part 5', 2, 'James Bond', 1964, '2022-08-11', 3, '8080');

SELECT * FROM [Item];


--- Testing the ItemStatusUpdateUponReturn procedure to update the CurentStatusID  

UPDATE Loan    
SET ReturnDate = GETDATE(), LoanStatusID = 1
WHERE LoanID = 3;

SELECT * FROM [Loan];





----To sort and classify memebers DOB------

select FullName, DateOfBirth,
CASE
WHEN DateOfBirth BETWEEN '1981-01-01' AND '1996-12-31' THEN 'MILLENIAL'
WHEN DateOfBirth >= '1998-01-01' THEN 'GENZ'
ELSE 'Other'
END AS GENERATION
FROM Member
ORDER BY  DateOfBirth


