CREATE TABLE "User" (
    user_id SERIAL NOT NULL,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    role varchar(50) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    email_verified bool DEFAULT false NOT NULL,
    phone_number varchar(20) NOT NULL UNIQUE,
    phone_verified bool DEFAULT false NOT NULL,
    registration_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
    password varchar(255) NOT NULL,
    city_id int4 NOT NULL,
    status bool DEFAULT true NOT NULL,
    PRIMARY KEY (user_id)
);
ALTER TABLE "User" ADD CONSTRAINT FK_User_City_city_id FOREIGN KEY (city_id) REFERENCES City (city_id);
CREATE INDEX User_city_id_idx ON "User" (city_id);



CREATE TABLE City (
    city_id SERIAL NOT NULL,
    name varchar(50) NOT NULL,
    PRIMARY KEY (city_id)
);
CREATE INDEX City_name_idx ON City (name);


CREATE TABLE Ticket (
    ticket_id SERIAL NOT NULL,
    league_id int4 NOT NULL,
    sport_id int4 NOT NULL,
    venue_id int4 NOT NULL,
    match_time timestamp NOT NULL,
    host_team_id int4 NOT NULL,
    guest_team_id int4 NOT NULL,
    remaining_capacity int4 NOT NULL,
    organizer_id int4 NOT NULL,
    PRIMARY KEY (ticket_id)
);
-- FOREIGN KEY
ALTER TABLE Ticket ADD CONSTRAINT FK_Ticket_Sport_sport_id FOREIGN KEY (sport_id) REFERENCES Sport (sport_id);
ALTER TABLE Ticket ADD CONSTRAINT FK_Ticket_Team_host_team_id FOREIGN KEY (host_team_id) REFERENCES Team (team_id);
ALTER TABLE Ticket ADD CONSTRAINT FK_Ticket_Team_guest_team_id FOREIGN KEY (guest_team_id) REFERENCES Team (team_id);
ALTER TABLE Ticket ADD CONSTRAINT FK_Ticket_Venue_venue_id FOREIGN KEY (venue_id) REFERENCES Venue (venue_id);
ALTER TABLE Ticket ADD CONSTRAINT FK_Ticket_League_league_id FOREIGN KEY (league_id) REFERENCES League (league_id);
ALTER TABLE Ticket ADD CONSTRAINT FK_Ticket_Organizer_organizer_id FOREIGN KEY (organizer_id) REFERENCES Organizer (organizer_id);
-- CHECK
ALTER TABLE Ticket ADD CONSTRAINT CHK_Ticket_Teams_Different CHECK (host_team_id <> guest_team_id);
ALTER TABLE Ticket ADD CONSTRAINT CHK_Ticket_Capacity_Positive CHECK (remaining_capacity >= 0);
-- INDEX
CREATE INDEX Ticket_sport_id_idx ON Ticket (sport_id);
CREATE INDEX Ticket_host_team_id_idx ON Ticket (host_team_id);
CREATE INDEX Ticket_guest_team_id_idx ON Ticket (guest_team_id);
CREATE INDEX Ticket_venue_id_idx ON Ticket (venue_id);
CREATE INDEX Ticket_league_id_idx ON Ticket (league_id);
CREATE INDEX Ticket_organizer_id_idx ON Ticket (organizer_id);
CREATE INDEX Ticket_match_time_idx ON Ticket (match_time);



CREATE TABLE Sport (
    sport_id SERIAL NOT NULL,
    sport_name varchar(50) NOT NULL,
    PRIMARY KEY (sport_id)
);
CREATE INDEX Sport_sport_name_idx ON Sport (sport_name);



CREATE TABLE Team (
    team_id SERIAL NOT NULL,
    team_name varchar(50) NOT NULL,
    sport_id int4 NOT NULL,
    city_id int4 NOT NULL,
    PRIMARY KEY (team_id)
);
-- FOREIGN KEY
ALTER TABLE Team ADD CONSTRAINT FK_Team_Sport_sport_id FOREIGN KEY (sport_id) REFERENCES Sport (sport_id);
ALTER TABLE Team ADD CONSTRAINT FK_Team_City_city_id FOREIGN KEY (city_id) REFERENCES City (city_id);
-- INDEX
CREATE INDEX Team_sport_id_idx ON Team (sport_id);
CREATE INDEX Team_city_id_idx ON Team (city_id);
CREATE INDEX Team_team_name_idx ON Team (team_name);



CREATE TABLE Venue (
    venue_id SERIAL NOT NULL,
    name varchar(50) NOT NULL,
    city_id int4 NOT NULL,
    full_address varchar(255) NOT NULL,
    PRIMARY KEY (venue_id)
);
-- FOREIGN KEY
ALTER TABLE Venue ADD CONSTRAINT FK_Venue_City_city_id FOREIGN KEY (city_id) REFERENCES City (city_id);
-- INDEX
CREATE INDEX Venue_city_id_idx ON Venue (city_id);
CREATE INDEX Venue_name_idx ON Venue (name);



CREATE TABLE Organizer (
    organizer_id SERIAL NOT NULL,
    is_company bool DEFAULT true NOT NULL,
    name varchar(50) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    phone_number varchar(20) NOT NULL UNIQUE,
    PRIMARY KEY (organizer_id)
);
-- CHECK
CREATE INDEX Organizer_name_idx ON Organizer (name);



CREATE TABLE Ticket_Details (
    ticket_id int4 NOT NULL,
    section int4 NOT NULL,
    row int4 NOT NULL,
    seat int4 NOT NULL,
    category_id int4 NOT NULL,
    price numeric(10, 2) NOT NULL,
    amenities varchar(255),
    -- A composite index is created, and it is suitable for queries based on
    -- (ticket_id), (ticket_id, section), (ticket_id, section, row), or (ticket_id, section, row, seat)
    PRIMARY KEY (ticket_id, section, row, seat)
);
-- FOREIGN KEY
ALTER TABLE Ticket_Details ADD CONSTRAINT FK_Ticket_Details_Ticket_ticket_id FOREIGN KEY (ticket_id) REFERENCES Ticket (ticket_id);
ALTER TABLE Ticket_Details ADD CONSTRAINT FK_Ticket_Details_Category_category_id FOREIGN KEY (category_id) REFERENCES Ticket_Category (category_id);
-- CHECK
ALTER TABLE Ticket_Details ADD CONSTRAINT CHK_Ticket_Details_Price_Positive CHECK (price >= 0);
-- INDEX
CREATE INDEX Ticket_Details_category_id_idx ON Ticket_Details (category_id);



CREATE TABLE League (
    league_id SERIAL NOT NULL,
    name varchar(50) NOT NULL,
    sport_id int4 NOT NULL,
    PRIMARY KEY (league_id)
);
-- FOREIGN KEY
ALTER TABLE League ADD CONSTRAINT FK_League_Sport_sport_id FOREIGN KEY (sport_id) REFERENCES Sport (sport_id);
-- UNIQUE
ALTER TABLE League ADD CONSTRAINT UQ_League_Sport_Name UNIQUE (sport_id, name);
-- INDEX
CREATE INDEX League_name_idx ON League (name);



CREATE TABLE Ticket_Category (
    category_id SERIAL NOT NULL,
    name varchar(50) NOT NULL,
    PRIMARY KEY (category_id)
);



CREATE TABLE Reservations (
    reservation_id SERIAL NOT NULL,
    user_id int4 NOT NULL,
    ticket_id int4 NOT NULL,
    section int4 NOT NULL,
    row int4 NOT NULL,
    seat int4 NOT NULL,
    price numeric(10, 2) NOT NULL,
    status varchar(50) NOT NULL,
    reservation_time timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expiration_time timestamp NOT NULL,
    PRIMARY KEY (reservation_id)
);
-- FOREIGN KEY
ALTER TABLE Reservations ADD CONSTRAINT FK_Reservations_User_user_id FOREIGN KEY (user_id) REFERENCES "User" (user_id);
ALTER TABLE Reservations ADD CONSTRAINT FK_Reservations_TicketDetails_seat FOREIGN KEY (ticket_id, section, row, seat) REFERENCES Ticket_Details (ticket_id, section, row, seat);
-- CHECK
ALTER TABLE Reservations ADD CONSTRAINT CHK_Reservations_Price_Positive CHECK (price >= 0);
ALTER TABLE Reservations ADD CONSTRAINT CHK_Reservations_Time_Logic CHECK (expiration_time > reservation_time);
-- INDEX
CREATE INDEX Reservations_user_id_idx ON Reservations (user_id);
CREATE INDEX Reservations_ticket_seat_idx ON Reservations (ticket_id, section, row, seat);



CREATE TABLE Payment (
    payment_id SERIAL NOT NULL,
    user_id int4 NOT NULL,
    wallet_id int4,
    reservation_id int4,
    type varchar(50) NOT NULL,
    method varchar(50) NOT NULL,
    status varchar(50) NOT NULL,
    time timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
    amount numeric(10, 2) NOT NULL,
    PRIMARY KEY (payment_id)
);
-- FOREIGN KEY
ALTER TABLE Payment ADD CONSTRAINT FK_Payment_User_user_id FOREIGN KEY (user_id) REFERENCES "User" (user_id);
ALTER TABLE Payment ADD CONSTRAINT FK_Payment_Reservations_reservation_id FOREIGN KEY (reservation_id) REFERENCES Reservations (reservation_id);
ALTER TABLE Payment ADD CONSTRAINT FK_Payment_Wallet_wallet_id FOREIGN KEY (wallet_id) REFERENCES Wallet (wallet_id);
-- CHECK
ALTER TABLE Payment ADD CONSTRAINT CHK_Payment_Amount_Positive CHECK (amount >= 0);
ALTER TABLE Payment ADD CONSTRAINT CHK_Payment_Target CHECK (wallet_id IS NOT NULL OR reservation_id IS NOT NULL);
-- INDEX
CREATE INDEX Payment_user_id_idx ON Payment (user_id);
CREATE INDEX Payment_wallet_id_idx ON Payment (wallet_id);
CREATE INDEX Payment_reservation_id_idx ON Payment (reservation_id);



CREATE TABLE Wallet (
    wallet_id SERIAL NOT NULL,
    user_id int4 NOT NULL UNIQUE,
    balance numeric(12, 2) DEFAULT 0 NOT NULL,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (wallet_id)
);
-- FOREIGN KEY
ALTER TABLE Wallet ADD CONSTRAINT FK_Wallet_User_user_id FOREIGN KEY (user_id) REFERENCES "User" (user_id);
-- CHECK
ALTER TABLE Wallet ADD CONSTRAINT CHK_Wallet_Balance_NonNegative CHECK (balance >= 0);



CREATE TABLE Report (
    report_id SERIAL NOT NULL,
    user_id int4 NOT NULL,
    support_id int4,
    reservation_id int4,
    payment_id int4,
    type varchar(255) NOT NULL,
    reported_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
    report varchar(255) NOT NULL,
    status varchar(50) NOT NULL,
    response varchar(255),
    responded_at timestamp,
    PRIMARY KEY (report_id)
);
-- FOREIGN KEY
ALTER TABLE Report ADD CONSTRAINT FK_Report_User_user_id FOREIGN KEY (user_id) REFERENCES "User" (user_id);
ALTER TABLE Report ADD CONSTRAINT FK_Report_User_support_id FOREIGN KEY (support_id) REFERENCES "User" (user_id);
ALTER TABLE Report ADD CONSTRAINT FK_Report_Payment_payment_id FOREIGN KEY (payment_id) REFERENCES Payment (payment_id);
ALTER TABLE Report ADD CONSTRAINT FK_Report_Reservations_reservation_id FOREIGN KEY (reservation_id) REFERENCES Reservations (reservation_id);
-- INDEX
CREATE INDEX Report_user_id_idx ON Report (user_id);
CREATE INDEX Report_support_id_idx ON Report (support_id);
CREATE INDEX Report_status_idx ON Report (status);