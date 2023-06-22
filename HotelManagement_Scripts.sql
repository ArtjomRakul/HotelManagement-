CREATE DATABASE HotelManagement
GO
USE HotelManagement
GO

CREATE TABLE PakalpojumaVeids (
    PakalpojumaVeidsID INT IDENTITY(1,1) PRIMARY KEY,
    Nosaukums VARCHAR(50) NOT NULL
);

CREATE TABLE Pakalpojums (
	PakalpojumaID INT IDENTITY(1,1) PRIMARY KEY,
	Nosaukums VARCHAR(50) NOT NULL,
	Apraksts VARCHAR(300),
	Cena DECIMAL(10, 2) NOT NULL CHECK (Cena >= 0),
	PakalpojumaVeidsID INT NOT NULL,
	FOREIGN KEY (PakalpojumaVeidsID) REFERENCES PakalpojumaVeids(PakalpojumaVeidsID)
);

CREATE TABLE Valsts (
    ValstsID INT IDENTITY(1,1) PRIMARY KEY,
    Nosaukums VARCHAR(50) NOT NULL
);

CREATE TABLE Viesis (
	ViesaID INT IDENTITY(1,1) PRIMARY KEY,
	Vards VARCHAR(50) NOT NULL,
	Uzvards VARCHAR(50) NOT NULL,
	Adrese VARCHAR(100),	
	E_pasts VARCHAR(50),
	Telefona_numurs VARCHAR(20) NOT NULL,
	ValstsID INT NOT NULL,
	Pasta_indekss VARCHAR(20),
	Dzimums CHAR(1) CHECK (Dzimums IN ('M', 'F')), -- Use CHAR instead of VARCHAR for fixed length fields, and add a CHECK constraint to enforce only M/F values
	Dzimsanas_datums DATE,
	Lietotajvards VARCHAR(50) UNIQUE NOT NULL, -- Add UNIQUE constraint for username field
	Parole VARCHAR(50) NOT NULL,
	PakalpojumaID  INT DEFAULT 1 NOT NULL,
	FOREIGN KEY (PakalpojumaID) REFERENCES Pakalpojums(PakalpojumaID),
	FOREIGN KEY (ValstsID) REFERENCES Valsts(ValstsID)
);

CREATE TABLE Pakalpojumu_izvele (
	IzvelesID INT IDENTITY(1,1) PRIMARY KEY,
	ViesaID INT NOT NULL,
	PakalpojumaID INT NOT NULL,
	FOREIGN KEY (ViesaID) REFERENCES Viesis(ViesaID),
	FOREIGN KEY (PakalpojumaID) REFERENCES Pakalpojums(PakalpojumaID)
);

CREATE TABLE Numurs (
	NumuraID INT IDENTITY(1,1) PRIMARY KEY,
	Nosaukums VARCHAR(100) NOT NULL,
	Apraksts VARCHAR(300),
	Stavs TINYINT NOT NULL CHECK (Stavs >= 0 AND Stavs <= 10), -- Use TINYINT for small integer fields and add a CHECK constraint for valid values
	Tips VARCHAR(20) NOT NULL,
	Ietilpiba TINYINT CHECK (Ietilpiba >= 1 AND Ietilpiba <= 4) NOT NULL, -- Add a CHECK constraint for valid values
	Cena DECIMAL(10, 2) NOT NULL CHECK (Cena >= 0), -- Add NOT NULL and CHECK constraints for price field
	PakalpojumaID INT DEFAULT 1 NOT NULL,
	Pieejamiba BIT DEFAULT 0,
	FOREIGN KEY (PakalpojumaID) REFERENCES Pakalpojums(PakalpojumaID)
);

CREATE TABLE Viesu_istaba (
	NumuraID INT NOT NULL,
	ViesaID INT NOT NULL,
	PRIMARY KEY (NumuraID, ViesaID),
	FOREIGN KEY (NumuraID) REFERENCES Numurs(NumuraID),
	FOREIGN KEY (ViesaID) REFERENCES Viesis(ViesaID)
);

CREATE TABLE RezervacijasStatuss (
    RezervacijasStatussID INT IDENTITY(1,1) PRIMARY KEY,
    Nosaukums VARCHAR(50) NOT NULL
);

CREATE TABLE Rezervacija (
    RezervacijasID INT IDENTITY(1,1) PRIMARY KEY,
    ViesaID INT NOT NULL,
    NumuraID INT NOT NULL,
    Datums_no DATE NOT NULL,
    Datums_lidz DATE NOT NULL,
    Rezervacijas_datums DATE NOT NULL DEFAULT GETDATE(),
    Pakalpojumu_skaits INT NOT NULL CHECK (Pakalpojumu_skaits >= 0),
    RezervacijasStatussID INT NOT NULL,
    FOREIGN KEY (ViesaID) REFERENCES Viesis(ViesaID),
    FOREIGN KEY (NumuraID) REFERENCES Numurs(NumuraID),
    FOREIGN KEY (RezervacijasStatussID) REFERENCES RezervacijasStatuss(RezervacijasStatussID),
    CONSTRAINT AK_Rezervacija_ViesaID_Datums_no UNIQUE (ViesaID, Datums_no),
    CONSTRAINT AK_Rezervacija_ViesaID_Datums_lidz UNIQUE (ViesaID, Datums_lidz)
);

CREATE TABLE Registracija (
	RegistracijasID INT IDENTITY(1,1) PRIMARY KEY,
	ViesaID INT NOT NULL,
	NumuraID INT NOT NULL,
	Datums DATE NOT NULL,
	FOREIGN KEY (ViesaID) REFERENCES Viesis(ViesaID),
	FOREIGN KEY (NumuraID) REFERENCES Numurs(NumuraID),
	FOREIGN KEY (ViesaID, Datums) REFERENCES Rezervacija(ViesaID, Datums_no)
);

CREATE TABLE Izrakstisana (
	IzrakstisanasID INT IDENTITY(1,1) PRIMARY KEY,
	ViesaID INT NOT NULL,
	NumuraID INT NOT NULL,
	Datums DATE NOT NULL,
	FOREIGN KEY (ViesaID) REFERENCES Viesis(ViesaID),
	FOREIGN KEY (NumuraID) REFERENCES Numurs(NumuraID),
  	FOREIGN KEY (ViesaID, Datums) REFERENCES Rezervacija(ViesaID, Datums_lidz)
);



INSERT INTO PakalpojumaVeids(Nosaukums)
VALUES
    ('Viesnīca un izmitināšana'), -- Accommodation
    ('Ēdināšana un dzērieni'), -- Food and Beverage
    ('SPA'), -- Spa
    ('Autonoma pakalpojumi'), -- Car Rental Services
    ('Tūrisma izbraukumi'), -- Sightseeing Tours
    ('Koncertu un izklaides pasākumi'), -- Concerts and Entertainment Events
    ('Sports'), -- Sports
    ('Bērnu aktivitātes'); -- Children's Activities

-- INSERT skripts Pakalpojums tabulas aizpildīšanai
INSERT INTO Pakalpojums (Nosaukums, Apraksts, Cena, PakalpojumaVeidsID) 
VALUES
('Numura uzkopšana', 'Iekļauj numura tīrīšanu un pārklāšanu ar svaigiem gultas veļas komplektiem', 0.00, 1),
('SPA procedūras', 'Relaksējoša masāža ar ēteriskajām eļļām', 50.00, 3),
('Kondicioniera nomā', 'Kondicioniera nomāšana uz istabu', 5.00, 1),
('Brokastu komplekts', 'Sastāv no kafijas, tējas, sulas, kruasāna, vistas omeletes un dārzeņu salātiem', 12.50, 1),
('Pusdienas komplekts', 'Sastāv no siltā ēdiena, salātiem un dzērieniem', 15.00, 1),
('Vakariņu komplekts', 'Sastāv no siltā ēdiena, salātiem, deserta un dzērieniem', 18.00, 1),
('Minibārs', 'Alkoholiskie un bezalkoholiskie dzērieni, saldumi un uzkodas', 30.00, 2),
('Autostāvvieta', 'Dienas laikā autostāvvieta uz vienu auto', 5.00, 4),
('Bērnu gultiņa', 'Bērnu gultiņas nomāšana uz istabu', 7.50, 1),
('Papildus gultasvece', 'Papildus gultasveces nomāšana uz istabu', 10.00, 1),
('Bezvadu internets', 'Ātrgaitas bezvadu internets uz istabu', 3.50, 1),
('Veļas mazgāšana', 'Veļas mazgāšanas pakalpojums', 12.00, 1),
('Dzīvnieku uzņemšana', 'Uzņemšana arī mājdzīvniekiem', 5.00, 1),
('Līnijas telefons', 'Līnijas tālrunis uz istabu', 7.00, 1),
('Seklais baseins', 'Seklais baseins ar bērnu laukumu', 5.00, 8),
('Dziļais baseins', 'Dziļais baseins ar hidromasāžu', 10.00, 7),
('Sauna', 'Saunas nomāšana uz 2h', 15.00, 3),
('Fitness centrs', 'Fitness centrs ar treniņa aprīkojumu', 10.00, 7),
('Papildu numura uzkopšana', 'Iekļauj papildu numura tīrīšanu un pārklāšanu ar svaigiem gultas veļas komplektiem', 4.99, 1),
('WiFi', 'Ātrākais bezvadu internets pilsētā', 5.99, 1),
('Autonoma parks', 'Drošs un drošs parks priekš jūsu automašīnām', 15.99, 4),
('Brokastis numurā', 'Svaigi gatavotas brokastis numurā', 10.00, 2),
('Pusdienas numurā', 'Svaigi gatavotas pusdienas numurā', 15.00, 2),
('Vakariņas numurā', 'Svaigi gatavotas vakariņas numurā', 20.00, 2),
('Mājas dzīvnieku pieņemšana', 'Pieņemam jūsu mājas dzīvniekus', 5.00, 1),
('Automašīnas noma', 'Nomas iespēja', 20.00, 4),
('Tūrisma informācija', 'Informācijas pakalpojumi', 0.00, 5),
('Ekskursijas', 'Ekskursijas pa tuvējiem apskates objektiem', 15.00, 5),
('Zāļu tējas', 'Dabīgie dzērieni viesiem', 1.00, 2),
('Šokolādes komplekts', 'Dāvana viesiem', 5.00, 2),
('Vīna komplekts', 'Dāvana viesiem', 10.00, 2),
('Sveces', 'Romantiska vakara noskaņa', 2.00, 1),
('Gaisa svaigāsana', 'Iekārtu iznomāšana', 10.00, 1),
('Maize', 'Garšīgs saldais ēdiens no mīkstas miltu mīklas', 2.99, 2),
('Zupa', 'Siltināta zupa no svaigiem dārzeņiem', 3.50, 2),
('Pasta', 'Spageti ar garšīgu tomātu mērci un sieru', 5.25, 2),
('Cepumi', 'Mīkstie cepumi ar šokolādes gabaliņiem', 1.99, 2),
('Kafija', 'Svaigi pagatavota kafija no labākajiem kafijas pupiņām', 2.50, 2),
('Tēja', 'Izsmalcināta tēja no labākajiem tējas lapām', 2.00, 2),
('Dzēriens', 'Atsvaidzinošs bezalkoholisks dzēriens ar citronu garšu', 1.50, 2),
('Pirts', 'Tradicionāla latviešu pirts ar ozolkoka slotām un ēteriskajām eļļām', 15.00, 3),
('Pēdu masāža', 'Relaksējoša pēdu masāža ar aromātiskajām eļļām', 20.00, 3),
('Ķermeņa masāža', 'Profesionāla ķermeņa masāža ar aromātiskajām eļļām', 35.00, 3),
('Yoga', 'Relaksējoša jogas nodarbība', 8.00, 7),
('Pilates', 'Profesionāla pilates nodarbība', 8.00, 7),
('Aerobika', 'Enerģisks aerobikas treniņš', 8.00, 7),
('Velo noma', 'Izbaudiet dabas skatus, braucot ar velosipēdu', 5.00, 6),
('Vēsturiska pils apskate', 'Iespēja apskatīt senatnīgas un iespaidīgas pilsētas pili', 14.30, 5),
('Koncerts', 'Mūzikas koncerts no vietējiem māksliniekiem', 20.00, 6),
('Futbola laukuma noma', 'Nomājiet mūsu futbola laukumu.', 10.00, 7);

INSERT INTO Valsts(Nosaukums)
VALUES
    ('Austrija'), -- Austria
    ('Beļģija'), -- Belgium
    ('Bulgārija'), -- Bulgaria
    ('Čehija'), -- Czech Republic
    ('Dānija'), -- Denmark
    ('Francija'), -- France
    ('Itālija'), -- Italy
    ('Īrija'), -- Ireland
    ('Īslande'), -- Iceland
    ('Japāna'), -- Japan
    ('Kipra'), -- Cyprus
    ('Latvija'), -- Latvia
    ('Lietuva'), -- Lithuania
    ('Luksemburga'), -- Luxembourg
    ('Malta'), -- Malta
    ('Nīderlande'), -- Netherlands
    ('Norvēģija'), -- Norway
    ('Polija'), -- Poland
    ('Portugāle'), -- Portugal
    ('Rumānija'), -- Romania
    ('Slovākija'), -- Slovakia
    ('Slovēnija'), -- Slovenia
    ('Somija'), -- Finland
    ('Spānija'), -- Spain
    ('Ungārija'), -- Hungary
    ('Vācija'), -- Germany
    ('Zviedrija'); -- Sweden

INSERT INTO Viesis (Vards, Uzvards, Adrese, E_pasts, Telefona_numurs, ValstsID, Pasta_indekss, Dzimums, Dzimsanas_datums, Lietotajvards, Parole, PakalpojumaID)
VALUES
	('Janis', 'Berzins', 'Rigas iela 1, Jelgava', 'janis.berzins@example.com', '+371-26633333', 12, '3001', 'M', '1990-01-01', 'janisb', 'parole123', default),
	('Liene', 'Ozola', 'Jurkalnes iela 10, Riga', 'liene.ozola@example.com', '+371-28611111', 12, '1009', 'F', '1995-05-05', 'lieneo', 'parole123', default),
	('Peteris', 'Saulitis', 'Piedrujas iela 2, Liepaja', 'peteris.saulitis@example.com', '+371-26322222', 12, '3101', 'M', '1985-03-10', 'peteriss', 'parole123', default),
	('Anna', 'Kalnina', 'Aizputes iela 15, Jelgava', 'anna.kalnina@example.com', '+371-29744444', 12, '3002', 'F', '2000-12-20', 'annak', 'parole123', default),
	('Edgars', 'Priede', 'Rubeņu iela 20, Riga', 'edgars.priede@example.com', '+371-24455555', 12, '1020', 'M', '1998-08-08', 'edgarsp', 'parole123', default),
	('Laura', 'Liepa', 'Rīgas iela 5, Liepāja', 'laura.liepa@example.com', '+371-26666666', 12, '3003', 'F', '1992-06-15', 'lauraliepa', 'parole123', default),
	('Māris', 'Bērziņš', 'Daugavpils iela 7, Rīga', 'maris.berzins@example.com', '+371-21111111', 12, '1002', 'M', '1987-09-20', 'marisberzins', 'parole123', default),
	('Inese', 'Ozola', 'Miera iela 12, Jūrmala', 'inese.ozola@example.com', '+371-28888888', 12, '2010', 'F', '1994-12-05', 'ineseozola', 'parole123', default),
	('Kaspars', 'Briedis', 'Lielā iela 3, Liepāja', 'kaspars.briedis@example.com', '+371-29999999', 12, '3004', 'M', '1991-04-25', 'kasparsbriedis', 'parole123', default),
	('Anita', 'Pētersone', 'Brīvības iela 50, Rīga', 'anita.petersone@example.com', '+371-23333333', 12, '1003', 'F', '1989-07-10', 'anitapetersone', 'parole123', default),
	('Hiroshi', 'Tanaka', '1-1-1 Shibuya, Tokyo', 'hiroshi.tanaka@example.com', '+81-123456789', 10, '10001', 'M', '1993-11-18', 'hiroshit', 'password123', default),
	('Sophie', 'Dubois', '10 Rue de la Paix, Paris', 'sophie.dubois@example.com', '+33-987654321', 6, '20002', 'F', '1990-07-25', 'sophied', 'password123', default),
	('Maximilian', 'Schmidt', 'Unter den Linden 10, Berlin', 'maximilian.schmidt@example.com', '+49-555555555', 26, '30003', 'M', '1995-03-12', 'maximilians', 'password123', default),
	('Isabella', 'Ricci', 'Via della Conciliazione 4, Rome', 'isabella.ricci@example.com', '+39-111111111', 7, '40004', 'F', '1998-09-30', 'isabellar', 'password123', default),
	('Javier', 'Garcia', 'Calle Gran Vía 50, Madrid', 'javier.garcia@example.com', '+34-222222222', 24, '50005', 'M', '1994-05-08', 'javierg', 'password123', default),
	('Aivaras', 'Butkus', '26 July Street, Zarasai', 'aivaras.but@example.com', '+372-123456789', 13, '70007', 'M', '1996-08-05', 'aivbut', 'password123', default),
	('Sofia', 'Andersson', 'Drottninggatan 1, Stockholm', 'sofia.andersson@example.com', '+46-777777777', 27, '80008', 'F', '1993-12-20', 'sofiaa', 'password123', default),
	('Sebastian', 'Müller', 'Kurfürstendamm 100, Berlin', 'sebastian.muller@example.com', '+49-999999999', 26, '30003', 'M', '1990-06-28', 'sebastianm', 'password123', default),
	('Chiara', 'Rossi', 'Piazza del Duomo 1, Milan', 'chiara.rossi@example.com', '+39-333333333', 7, '40004', 'F', '1997-03-15', 'chiarar', 'password123', default),
	('Jakob', 'Müller', 'Schönbrunner Schloßstraße 47, Vienna', 'jakob.muller@example.com', '+43-123456789', 1, '90009', 'M', '1992-07-14', 'jakobm', 'password123', default),
	('Emma', 'Dubois', 'Rue Royale 15, Brussels', 'emma.dubois@example.com', '+32-987654321', 2, '10001', 'F', '1995-02-28', 'emmad', 'password123', default),
	('Viktor', 'Ivanov', 'ul. Alabin 7, Sofia', 'viktor.ivanov@example.com', '+359-123456789', 3, '20002', 'M', '1991-11-15', 'viktori', 'password123', default),
	('Tomas', 'Novak', 'Vodičkova 5, Prague', 'tomas.novak@example.com', '+420-111111111', 4, '30003', 'M', '1994-10-08', 'tomasn', 'password123', default),
	('Freja', 'Hansen', 'Nyhavn 10, Copenhagen', 'freja.hansen@example.com', '+45-222222222', 5, '50005', 'F', '1996-06-20', 'frejah', 'password123', default),
	('Hans', 'Müller', 'Am Ring 1, Vienna', 'hans.muller@example.com', '+43-123456789', 1, '10001', 'M', '1990-02-15', 'hansm', 'password123', default),
	('Sophie', 'Leclerc', 'Rue Royale 10, Brussels', 'sophie.leclerc@example.com', '+32-987654321', 2, '20002', 'F', '1995-06-10', 'sophiel', 'password123', default),
	('Georgi', 'Ivanov', 'Sofia Street 5, Sofia', 'georgi.ivanov@example.com', '+359-123456789', 3, '30003', 'M', '1992-11-25', 'georgii', 'password123', default),
	('Jakub', 'Novák', 'Na Příkopě 10, Prague', 'jakub.novak@example.com', '+420-123456789', 4, '40004', 'M', '1988-10-12', 'jakubn', 'password123', default),
	('Maja', 'Andersen', 'Højbro Plads 5, Copenhagen', 'maja.andersen@example.com', '+45-12345678', 5, '50005', 'F', '1993-04-28', 'majaa', 'password123', default),
	('Pierre', 'Dupont', 'Champs-Élysées 20, Paris', 'pierre.dupont@example.com', '+33-987654321', 6, '60006', 'M', '1991-09-05', 'pierred', 'password123', default),
	('Anna', 'Schmidt', 'Hauptstraße 1, Berlin', 'anna.schmidt@example.com', '+49-12345678', 26, '70007', 'F', '1989-07-18', 'annas', 'password123', default),
	('Gábor', 'Magy', 'Váci Street 1, Budapest', 'gabor.magy@example.com', '+36-123456789', 25, '90009', 'M', '1990-12-02', 'gaborm', 'password123', default),
	('Aoife', 'Gatsby', 'Grafton Street 5, Dublin', 'aoife.gatsby@example.com', '+353-123456789', 8, '10010', 'F', '1993-11-15', 'aoifeg', 'password123', default),
	('Lotte', 'Jansen', 'Dam Square 1, Amsterdam', 'lotte.jansen@example.com', '+31-123456789', 16, '12012', 'F', '1995-04-25', 'lottej', 'password123', default),
	('Adam', 'Kowalski', 'Nowy Świat 10, Warsaw', 'adam.kowalski@example.com', '+48-123456789', 18, '13013', 'M', '1990-08-20', 'adamk', 'password123', default),
	('Maria', 'Santos', 'Rua Augusta 25, Lisbon', 'maria.santos@example.com', '+351-123456789', 19, '14014', 'F', '1993-02-12', 'marias', 'password123', default),
	('Carlos', 'García', 'Gran Vía 5, Madrid', 'carlos.garcia@example.com', '+34-123456789', 24, '15015', 'M', '1988-12-30', 'carlos', 'password123', default),
	('Emma', 'Andersson', 'Drottninggatan 1, Stockholm', 'emma.andersson@example.com', '+46-123456789', 27, '16016', 'F', '1991-05-08', 'emmaa', 'password123', default),
	('Marco', 'Rossi', 'Via del Corso 15, Rome', 'marco.rossi@example.com', '+39-123456789', 7, '11011', 'M', '1992-06-10', 'marcor', 'password123', default),
	('Sophie', 'Martin', 'Champs-Élysées 10, Paris', 'sophie.martin@example.com', '+33-123456789', 6, '17017', 'F', '1994-09-15', 'sophiem', 'password123', default),
	('Alexander', 'Schmidt', 'Brandenburg Gate 1, Berlin', 'alexander.schmidt@example.com', '+49-123456789', 26, '18018', 'M', '1996-11-05', 'alexanders', 'password123', default),
	('Gábor', 'Nagy', 'Andrássy Avenue 3, Budapest', 'gabor.nagy@example.com', '+36-123456789', 25, '20020', 'M', '1989-03-10', 'gaborn', 'password123', default),
	('Aoife', 'Murphy', 'Grafton Street 15, Dublin', 'aoife.murphy@example.com', '+353-123456789', 8, '21021', 'F', '1993-12-08', 'aoifem', 'password123', default),
	('Alessandro', 'Ricci', 'Colosseum Square 1, Rome', 'alessandro.ricci@example.com', '+39-123456789', 7, '22022', 'M', '1990-05-03', 'alessandror', 'password123', default),
	('Sofía', 'González', 'Puerta del Sol 2, Madrid', 'sofia.gonzalez@example.com', '+34-123456789', 24, '23023', 'F', '1995-08-27', 'sofiag', 'password123', default),
	('Miguel', 'Silva', 'Avenida da Liberdade 7, Lisbon', 'miguel.silva@example.com', '+351-123456789', 19, '24024', 'M', '1991-02-14', 'miguels', 'password123', default),
	('Maximilian', 'Weber', 'Ringstrasse 4, Vienna', 'maximilian.weber@example.com', '+43-123456789', 1, '26026', 'M', '1994-04-18', 'maximilianw', 'password123', default),
	('Sophie', 'Jansen', 'Dam Square 1, Amsterdam', 'sophie.jansen@example.com', '+31-123456789', 16, '27027', 'F', '1993-06-08', 'sophiej', 'password123', default),
	('Emma', 'Larsson', 'Drottninggatan 1, Stockholm', 'emma.larsson@example.com', '+46-123456789', 27, '29029', 'F', '1992-12-15', 'emmal', 'password123', default),
	('Oliver', 'Haugen', 'Karl Johans gate 2, Oslo', 'oliver.haugen@example.com', '+47-123456789', 17, '30030', 'M', '1998-03-21', 'oliverh', 'password123', default),
	('Freya', 'Andersen', 'Tivoli Gardens 1, Copenhagen', 'freya.andersen@example.com', '+45-123456789', 5, '31031', 'F', '1999-07-09', 'freyaa', 'password123', default),
	('Aleksandrs', 'Vīskna', 'Smilšu iela 18, Rīga', 'viksna.aleksandrs@example.com', '+371-123456789', 12, '2001', 'M', '2000-01-01', 'aleksvik', 'password123', default),
	('Aleksandra', 'Vīskne', 'Smilšu iela 18, Rīga', 'viksne.aleksandra@example.com', '+371-123456799', 12, '2001', 'F', '1999-01-01', 'aleksvika', 'password123', default),
	('Evelīna', 'Zviedriņa', 'Mājas iela 2, Jelgava', 'evelina.zviedrina@example.com', '+371-123456669', 12, '2015', 'F', '1999-10-10', 'evezviedr', 'password123', default),
	('Dmitrijs', 'Ābols', 'Maijas iela 20, Ventspils', 'dmitrijs.abols@example.com', '+371-223456879', 12, '1001', 'M', '1998-06-17', 'dmitrabols', 'password123', default);

INSERT INTO Pakalpojumu_izvele (ViesaID, PakalpojumaID)
VALUES 
	(1, 2), 
	(1, 3),
	(2, 5),
	(3, 1),
	(2, 4),
	(4, 4),
	(5, 6),
	(6, 5), 
	(7, 3),
	(7, 25),
	(7, 11),
	(7, 4),
	(8, 44),
	(8, 36),
	(9, 2), 
	(10, 3),
	(11, 25),
	(11, 11),
	(11, 14),
	(12, 24),
	(12, 36),
	(13, 32), 
	(13, 43),
	(13, 5),
	(13, 11),
	(13, 24),
	(14, 34),
	(15, 36),
	(16, 22), 
	(17, 3),
	(17, 15),
	(17, 41),
	(17, 24),
	(17, 14),
	(17, 36),
	(18, 22), 
	(18, 13),
	(19, 15),
	(19, 11),
	(20, 14),
	(20, 24),
	(21, 36),
	(21, 42), 
	(22, 13),
	(23, 15),
	(24, 21),
	(24, 24),
	(24, 4),
	(24, 6),
	(24, 22), 
	(24, 3),
	(25, 5),
	(25, 21),
	(26, 44),
	(27, 14),
	(28, 6),
	(29, 22), 
	(30, 33),
	(31, 5),
	(32, 32),
	(33, 4),
	(34, 44),
	(35, 6),
	(36, 12), 
	(36, 13),
	(36, 5),
	(37, 41),
	(38, 4),
	(38, 24),
	(39, 6),
	(40, 2), 
	(41, 13),
	(42, 5),
	(43, 31),
	(44, 24),
	(45, 4),
	(46, 6),
	(38, 44),
	(38, 4),
	(39, 6),
	(40, 2), 
	(41, 3),
	(42, 5),
	(43, 31),
	(44, 14),
	(45, 4),
	(46, 6),
	(47, 24),
	(47, 4),
	(48, 26),
	(49, 2), 
	(50, 3),
	(50, 5),
	(50, 21),
	(51, 44),
	(51, 4),
	(51, 6),
	(52, 18),
	(53, 19),
	(54, 20);

INSERT INTO Numurs (Nosaukums, Apraksts, Stavs, Tips, Ietilpiba, Cena, PakalpojumaID, Pieejamiba)
VALUES
('Standard numurs', 'Standarta numurs ar vienu gultu', 8, 'Vienistabas', 1, 50.00, default, 1),
('Komforta numurs', 'Numurs ar divām gultām un papildus aprīkojumu', 9, 'Divistabas', 2, 70.00, default, 1),
('Deluxe numurs', 'Izsmalcināts numurs ar vannu un skatu uz jūru', 10, 'Divistabas', 2, 100.00, default, 1),
('Ģimenes numurs', 'Numurs ar divām guļvietām un divām atsevišķām istabām', 9, 'Divistabas', 4, 120.00, default, 1),
('Penthouse numurs', 'Luksusa dzīvoklis ar privātu terasi un skatu uz pilsētu', 10, 'Apartamenti', 4, 200.00, default, 1),
('Ekonoms numurs', 'Vienistabas numurs ar pamata aprīkojumu', 6, 'Vienistabas', 1, 30.00, default, 1),
('Romantiskais numurs', 'Numurs ar king-size gultu un romantisku interjeru', 8, 'Vienistabas', 1, 60.00, default, 1),
('Skatu numurs 101', 'Standarta numurs ar skatu uz dārzu', 8, 'Standarta', 2, 80.00, default, 1),
('Premium jūras skatu numurs', 'Premium numurs ar skatu uz jūru', 9, 'Premium', 2, 120.00, default, 1),
('Pilsētas skatu numurs 103', 'Standarta numurs ar skatu uz pilsētu', 7, 'Standarta', 2, 90.00, default, 1),
('Ģimenes numurs ar dārza skatu', 'Numurs ar divām guļamistabām un skatu uz dārzu', 9, 'Ģimenes', 4, 180.00, default, 1),
('Ģimenes numurs ar jūras skatu', 'Numurs ar divām guļamistabām un skatu uz jūru', 10, 'Ģimenes', 4, 220.00, default, 1),
('Ģimenes numurs ar pilsētas skatu', 'Numurs ar divām guļamistabām un skatu uz pilsētu', 8, 'Ģimenes', 4, 200.00, default, 1),
('Ekskluzīvs numurs ar privātu baseinu', 'Ekskluzīvs numurs ar privātu baseinu', 10, 'Ekskluzīvs', 2, 250.00, default, 1),
('Luksusa numurs ar dārza skatu un dzīvojamo istabu', 'Plašs luksusa numurs ar skatu uz dārzu un atsevišķu dzīvojamu istabu', 9, 'Luksusa', 2, 300.00, default, 1),
('VIP apartaments ar skatu uz pilsētu un privātu džakūzi', 'VIP apartaments ar plašu guļamistabu, viesistabu, džakūzi un skatu uz pilsētu', 10, 'VIP', 2, 400.00, default, 1),
('Romantiskais numurs ar skatu uz jūru', 'Mājīgs numurs ar romantisku atmosfēru un ainavu uz jūru', 5, 'Romantiskais', 2, 250.00, default, 1),
('Ģimenes numurs ar divām guļamistabām', 'Ērti iekārtots numurs ģimenei ar divām guļamistabām un atpūtas zonu', 3, 'Ģimenes', 4, 350.00, default,1),
('Pirmskāpju numurs ar privātu sauna kompleksu', 'Ekskluzīvs numurs ar pirmskāpju telpu un privātu sauna kompleksu', 6, 'Ekskluzīvs', 2, 500.00, default, 1),
('Ekskluzīvais suits ar privātu baseinu', 'Luksusa klases suits ar privātu baseinu un plašu terasi', 8, 'Suite', 2, 800.00, default, 1),
('Stilīgais numurs ar pilsētas panorāmas skatu', 'Moderns numurs ar eleganto dizainu un iespaidīgu pilsētas panorāmas skatu', 10, 'Stilīgais', 2, 400.00, default, 1),
('Mājīgais numurs ar dīvānu un kamīnu', 'Mājīgs numurs ar ērtu dīvānu, kamīnu un siltu atmosfēru', 5, 'Mājīgais', 2, 200.00, default, 1),
('Numurs ar balkonu un skatu uz dārzu', 'Skaists numurs ar privātu balkonu un skaistu skatu uz viesnīcas dārzu', 4, 'Standarta', 2, 150.00, default, 1),
('Viesistaba ar skatu uz jūru', 'Mājīga viesistaba ar plašām durvīm, kas atveras uz burvīgu skatu uz jūru', 7, 'Vienistabas', 1, 100.00, default, 1),
('Plašs dzīvoklis ar virtuvi', 'Komfortabls dzīvoklis ar pilnībā aprīkotu virtuvi un atsevišķu guļamistabu', 6, 'Dzīvoklis', 4, 250.00, default, 1), -- 25
('Ģimenes numurs ar divām guļamistabām', 'Ērts numurs, kas piemērots ģimenēm ar divām atsevišķām guļamistabām', 3, 'Ģimenes', 4, 300.00, default, 0),
('Numurs ar privāto džakuzi', 'Ekskluzīva suite ar plašu dzīvojamo telpu un privātu džakuzi', 9, 'Suite', 2, 700.00, default, 1),
('Ekskluzīvais apartaments ar skatu uz pilsētu', 'Izcils apartaments ar panorāmas skatu uz pilsētu un modernu dizainu', 5, 'Apartamenti', 2, 800.00, default, 1),
('Romantiska guļamistaba ar kamīnu', 'Burvīga guļamistaba ar romantisku atmosfēru, privātu kamīnu un balkonu', 5, 'Guļamistaba', 2, 400.00, default, 0),
('Klasiskās stilā iekārtots numurs', 'Mājīgs un elegantā klasiskā stilā iekārtots numurs ar visiem ērtībām', 4, 'Standarta', 2, 200.00, default, 1),
('VIP luksusa numurs ar personīgo butleru', 'Visaugstākās klases numurs ar personīgo butleru, privāto baseinu un atsevišķu spa zonu', 10, 'VIP', 2, 1500.00, default, 0),
('Ekskluzīvais penthouse ar skatu uz jūru', 'Greznības pilns penthouse ar plašu terasi un aizraujošu skatu uz jūru', 10, 'Penthouse', 4, 2500.00, default, 0),
('Ģimenes numurs ar divām guļamistabām', 'Ērts numurs ar divām guļamistabām, piemērots ģimenei ar bērniem', 8, 'Ģimenes', 4, 600.00, default, 0),
('Luksusa viesnīcas dzīvoklis', 'Plašs un moderns dzīvoklis ar virtuvi, viesistabu un atsevišķu guļamistabu', 10, 'Dzīvoklis', 3, 1000.00, default, 0),
('Klasiskās stilā iekārtots numurs ar balkonu', 'Elegants un mājīgs numurs ar klasisko interjeru un skaistu balkonu', 6, 'Standarta', 2, 350.00, default, 0),
('Romantiskais studijas dzīvoklis ar skatu uz pilsētu', 'Mājīgs un romantisks dzīvoklis ar vienu guļamistabu un lielisku skatu uz pilsētu', 5, 'Dzīvoklis', 2, 400.00, default, 0),
('Elegants numurs ar divām vannas istabām', 'Stilīgs un elegants numurs ar divām vannas istabām un modernu iekārtu', 9, 'Standarta', 4, 700.00, default, 0),
('Luksusa suite ar privātu baseinu', 'Greznīgs suite ar plašu dzīvojamās istabas telpu, privātu baseinu un pilnībā aprīkotu virtuvi', 5, 'Suite', 2, 1500.00, default, 0),
('Komfortabls numurs ar darba stūrīti', 'Numurs ar visu nepieciešamo komfortam un ērtu darba stūrīti', 4, 'Standarta', 2, 300.00, default, 0),
('Ekskluzīvs penthouse ar skatu uz jūru', 'Plašs penthouse dzīvoklis ar iespaidīgu skatu uz jūru, privātu terasi un modernu iekārtu', 10, 'Dzīvoklis', 4, 2500.00, default, 0),
('Komfortabls numurs ar dārza skatu', 'Mājīgs numurs ar burvīgu dārza skatu, divām guļamistabām un modernu iekārtu', 7, 'Standarta', 4, 600.00, default, 0),
('Ģimenes apartaments ar bērnu istabu', 'Plašs un ērti iekārtots apartaments, kas piemērots ģimenei ar bērniem, ar atsevišķu bērnu istabu', 10, 'Ģimenes', 4, 800.00, default, 0),
('Romantisks numurs ar džakūzī', 'Intīma un romantiska numurs ar lielu džakūzī, kamīnu un privātu terasi', 8, 'Suite', 2, 1200.00, default, 0),
('Elegants numurs ar pilsētas panorāmu', 'Moderns un elegants numurs ar iespaidīgu pilsētas panorāmu, iekārtu augstākajā līmenī', 5, 'Standarta', 2, 800.00, default, 1),
('Boutique stila dzīvoklis', 'Mājīgs un stilīgs dzīvoklis boutique stilā ar modernām mēbelēm un kvalitatīvu apdari', 5, 'Dzīvoklis', 3, 900.00, default, 0),
('Superior numurs ar balkonu', 'Ietilpīgs superior numurs ar privātu balkonu, kur var baudīt svaigu gaisu un ainavu', 10, 'Standarta', 2, 700.00, default, 0),
('Luksusa numurs ar privātu baseinu', 'Greznības pilns numurs ar privātu baseinu, augstas klases mēbeļu komplektu un atpūtas zonu', 2, 'Suite', 2, 2500.00, default, 0),
('Ekskluzīvs numurs ar privātu dārzu', 'Plašs un mājīgs numurs ar ekskluzīvu privātu dārzu, ideāli piemērots ģimenes atpūtai', 2, 'Standarta', 4, 1200.00, default, 0),
('Romantisks divvietīgs numurs ar džakūzi', 'Intīms un romantisks numurs ar privātu džakūzi un noslēpumainu atmosfēru', 6, 'Romantiskais', 2, 950.00, default, 0),
('Eko-stila numurs ar dabas elementiem', 'Mūsdienīgs numurs ar ekoloģisku dizainu, kurā izmantoti dabas materiāli un elementi', 4, 'Standarta', 2, 850.00, default, 0),
('Deluxe numurs ar privātu terasi', 'Greznīgs suite ar plašu privātu terasi, kas piedāvā apbrīnojamu skatu uz apkārtējo ainavu', 8, 'Suite', 2, 2000.00, default, 0),
('Standard numurs ar balkonu', 'Standarta numurs ar vienu gultu un balkonu', 8, 'Vienistabas', 1, 50.00, default, 1),
('Standard numurs', 'Standarta numurs ar divām gultām', 8, 'Divistabas', 2, 50.00, default, 1);

INSERT INTO Viesu_istaba(NumuraID, ViesaID)
VALUES
	(1, 1),
	(2, 2),
	(2, 3),
	(3, 4),
	(3, 5),
	(3, 6),
	(4, 7),
	(4, 8),
	(4, 9),
	(4, 10),
	(5, 11),
	(6, 12),
	(7, 13),
	(8, 14),
	(9, 15),
	(9, 16),
	(10, 17),
	(11, 18),
	(11, 19),
	(12, 20),
	(12, 21),
	(12, 22),
	(13, 23),
	(13, 24),
	(13, 25),
	(13, 26),
	(14, 27),
	(14, 28),
	(15, 29),
	(16, 30),
	(17, 31),
	(18, 32),
	(18, 33),
	(19, 34),
	(19, 35),
	(20, 36),
	(20, 37),
	(21, 38),
	(22, 39),
	(22, 40),
	(23, 41),
	(24, 42),
	(25, 43),
	(27, 44),
	(27, 45),
	(28, 46),
	(28, 47),
	(30, 48),
	(30, 49),
	(43, 50),
	(43, 51),
	(52, 52),
	(52, 53),
	(51, 54);


INSERT INTO RezervacijasStatuss(Nosaukums)
VALUES
    ('Apstiprināts'), -- Confirmed
	('Pārvietots'), -- Moved
    ('Ieķērās'), -- Checked-In
    ('Izrakstīts'), -- Checked-Out
    ('Gaida apstiprinājumu'), -- Pending Confirmation
    ('Nepieciešama darbība'), -- Action Required
    ('Atcelts');

INSERT INTO Rezervacija (ViesaID, NumuraID, Datums_no, Datums_lidz, Rezervacijas_datums, Pakalpojumu_skaits, RezervacijasStatussID)
VALUES
     (1, 1, '2023-05-01', '2023-05-17', '2023-01-11', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 1), 3),
     (2, 2, '2023-07-10', '2023-07-20', '2023-02-12', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 2), 1),
     (4, 3, '2023-08-15', '2023-08-20', '2023-03-04', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 4), 1),
     (7, 4, '2023-05-06', '2023-05-14', '2023-04-22', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 7), 4),
     (11, 5, '2023-07-10', '2023-07-15', '2023-05-13', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 11), 6),
     (12, 6, '2023-08-01', '2023-08-10', '2023-01-11', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 12), 5),
     (13, 7, '2023-09-15', '2023-09-20', '2023-02-24', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 13), 6),
     (14, 8, '2023-10-01', '2023-10-05', '2023-03-01', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 14), 5),
     (15, 9, '2023-11-15', '2023-11-20', '2023-04-02', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 15), 1),
     (17, 10, '2023-12-01', '2023-12-05', '2023-05-14', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 17), 1),
  	 (18, 11, '2023-05-10', '2023-05-20', '2023-02-18', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 18), 3),
  	 (20, 12, '2023-05-01', '2023-05-22', '2023-03-19', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 20), 3),
  	 (23, 13, '2023-06-01', '2023-06-22', '2023-05-20', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 23), 5),
     (27, 14, '2023-06-10', '2023-06-15', '2023-05-22', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 27), 6),
	(29, 15, '2023-06-21', '2023-07-01', '2023-05-21', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 29), 1),
	(30, 16, '2023-07-04', '2023-07-14', '2023-01-07', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 30), 5),
	(31, 17, '2023-07-10', '2023-07-15', '2023-02-08', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 31), 5),
	(32, 18, '2023-08-15', '2023-08-20', '2023-03-09', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 32), 1),
    (34, 19, '2023-09-01', '2023-09-05', '2023-01-06', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 34), 5),
(36, 20, '2023-10-10', '2023-10-15', '2023-02-05', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 36), 6),
(38, 21, '2023-11-15', '2023-11-20', '2023-03-03', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 38), 6),
(39, 22, '2023-12-01', '2023-12-05', '2023-01-16', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 39), 1),
(41, 23, '2023-08-10', '2023-08-15', '2023-02-18', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 41), 1),
(42, 24, '2023-08-11', '2023-08-23', '2023-04-19', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 42), 2),
(43, 25, '2023-09-01', '2023-09-15', '2023-05-15', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 43), 1),
(44, 27, '2023-09-07', '2023-09-21', '2023-01-14', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 44), 2),
(46, 28, '2023-09-12', '2023-09-25', '2023-02-23', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 46), 2),
(48, 30, '2023-10-02', '2023-10-09', '2023-02-21', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 48), 1),
(50, 43, '2023-10-01', '2023-10-19', '2023-02-27', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 50), 2),
(52, 52, '2023-10-10', '2023-10-15', '2023-02-28', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 52), 2),
(54, 51, '2023-11-17', '2023-11-25', '2023-04-01', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 54), 5),
(55, 47, '2023-11-20', '2023-11-27', '2023-02-01', (SELECT COUNT(*) FROM Pakalpojumu_izvele WHERE ViesaID = 55), 7);

INSERT INTO Registracija (ViesaID, NumuraID, Datums)
VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-07-10'),
(4, 3, '2023-08-15'),
(7, 4, '2023-05-06'),
(11, 5, '2023-07-10'),
(12, 6, '2023-08-01'),
(13, 7, '2023-09-15'),
(14, 8, '2023-10-01'),
(15, 9, '2023-11-15'),
(17, 10, '2023-12-01'),
(18, 11, '2023-05-10'),
(20, 12, '2023-05-01'),
(23, 13, '2023-06-01'),
(27, 14, '2023-06-10'),
(29, 15, '2023-06-21'),
(30, 16, '2023-07-04'),
(31, 17, '2023-07-10'),
(32, 18, '2023-08-15'),
(34, 19, '2023-09-01'),
(36, 20, '2023-10-10'),
(38, 21, '2023-11-15'),
(39, 22, '2023-12-01'),
(41, 23, '2023-08-10'),
(42, 24, '2023-08-11'),
(43, 25, '2023-09-01'),
(44, 27, '2023-09-07'),
(46, 28, '2023-09-12'),
(48, 30, '2023-10-02'),
(50, 43, '2023-10-01'),
(52, 52, '2023-10-10'),
(54, 51, '2023-11-17');

INSERT INTO Izrakstisana (ViesaID, NumuraID, Datums)
VALUES

(1, 1, '2023-05-17'),
(2, 2, '2023-07-20'),
(4, 3, '2023-08-20'),
(7, 4, '2023-05-14'),
(11, 5,'2023-07-15'),
(12, 6,'2023-08-10'),
(13, 7,'2023-09-20'),
(14, 8,'2023-10-05'),
(15, 9,'2023-11-20'),
(17, 10,'2023-12-05'),
(18, 11,'2023-05-20'),
(20, 12,'2023-05-22'),
(23, 13,'2023-06-22'),
(27, 14,'2023-06-15'),
(29, 15,'2023-07-01'),
(30, 16,'2023-07-14'),
(31, 17,'2023-07-15'),
(32, 18,'2023-08-20'),
(34, 19,'2023-09-05'),
(36, 20,'2023-10-15'),
(38, 21,'2023-11-20'),
(39, 22,'2023-12-05'),
(41, 23,'2023-08-15'),
(42, 24,'2023-08-23'),
(43, 25,'2023-09-15'),
(44, 27,'2023-09-21'),
(46, 28,'2023-09-25'),
(48, 30,'2023-10-09'),
(50, 43,'2023-10-19'),
(52, 52,'2023-10-15'),
(54, 51,'2023-11-25');

--Atskaites, kas parāda visvairāk izmantotos pakalpojumu veidus un to vidējo cenu katram viesim.
SELECT 
    PV.Nosaukums AS Pakalpojuma_veids, 
    COUNT(*) AS Reizes_izmantots, 
    AVG(P.Cena) AS Videja_cena_viesim
FROM Pakalpojums AS P
INNER JOIN PakalpojumaVeids AS PV ON P.PakalpojumaVeidsID = PV.PakalpojumaVeidsID
INNER JOIN Pakalpojumu_izvele AS PI ON P.PakalpojumaID = PI.PakalpojumaID
INNER JOIN Rezervacija AS R ON R.ViesaID = PI.ViesaID
GROUP BY PV.Nosaukums
ORDER BY Reizes_izmantots DESC;

--Atskaites, kas attēlo viesu skaitu, kuri izmanto pakalpojumu veidu, kas ir vispopulārākais (t.i. visvairāk izmantotais) viesnīcā.
SELECT PV.Nosaukums AS Pakalpojuma_veids, COUNT(*) AS Viesu_skaits
FROM PakalpojumaVeids PV
JOIN Pakalpojums P ON PV.PakalpojumaVeidsID = P.PakalpojumaVeidsID
JOIN Pakalpojumu_izvele PI ON P.PakalpojumaID = PI.PakalpojumaID
JOIN Rezervacija R ON PI.ViesaID = R.ViesaID AND R.Datums_lidz >= GETDATE()
GROUP BY PV.Nosaukums
ORDER BY COUNT(*) DESC;

--Atskaites par viesiem, kuri visvairāk izmanto pakalpojumus (TOP 10)
SELECT TOP 10 Viesis.Vards, Viesis.Uzvards, COUNT(Pakalpojumu_izvele.IzvelesID) AS Pakalpojumu_skaits
FROM Viesis
JOIN Pakalpojumu_izvele ON Viesis.ViesaID = Pakalpojumu_izvele.ViesaID
GROUP BY Viesis.Vards, Viesis.Uzvards
ORDER BY Pakalpojumu_skaits DESC;

--Izveido atskaiti, kas rāda, kura numura veida (tips) numuri ir visvairāk pieprasīti, 
--un cik daudz reižu katrai numura veidu grupai ir pieprasīta numuru ietilpība (ietilpība).
SELECT n.Tips, n.Ietilpiba, COUNT(*) AS Pieprasijumu_skaits
FROM Numurs n 
JOIN Rezervacija r ON n.NumuraID = r.NumuraID
GROUP BY n.Tips, n.Ietilpiba
ORDER BY Pieprasijumu_skaits DESC;

--Atskaite par numuru pieejamību pēc kategorijas.
SELECT Tips, COUNT(*) as Pieejamie_numuri
FROM Numurs 
WHERE Pieejamiba = 0 
GROUP BY Tips
ORDER BY Tips ASC;

--Visa informācija par katru viesi.
SELECT V.ViesaID, V.Vards, V.Uzvards, V.Adrese, V.E_pasts, V.Telefona_numurs,
V.Pasta_indekss, V.Dzimums, V.Dzimsanas_datums, V.Lietotajvards
, COUNT(PI.IzvelesID) AS Pakalpojumu_skaits,
R.RezervacijasID
FROM Viesis V
INNER JOIN Pakalpojums P ON V.PakalpojumaID = P.PakalpojumaID
LEFT JOIN Pakalpojumu_izvele PI ON V.ViesaID = PI.ViesaID
LEFT JOIN Rezervacija R ON V.ViesaID = R.ViesaID
GROUP BY V.ViesaID, V.Vards, V.Uzvards, V.Adrese, V.E_pasts, V.Telefona_numurs,
V.Pasta_indekss, V.Dzimums, V.Dzimsanas_datums, V.Lietotajvards, R.RezervacijasID
ORDER BY R.RezervacijasID DESC;

--Atskaites, kas parāda, cik daudz rezervāciju ir veiktas katrā mēnesī un 
--kuri ir visvairāk rezervētie numuri pēc kopējās rezervāciju skaita katrā mēnesī.
SELECT 
    MONTH(R.Datums_no) AS Menesis, 
    COUNT(*) AS Rezervaciju_skaits, 
    N.Nosaukums AS Numura_nosaukums, 
    COUNT(*) OVER (PARTITION BY MONTH(R.Datums_no) ORDER BY COUNT(*) DESC) AS Numura_rezervaciju_skaits
FROM Rezervacija AS R
INNER JOIN Numurs AS N ON N.NumuraID = R.NumuraID
GROUP BY MONTH(R.Datums_no), N.Nosaukums
ORDER BY MONTH(R.Datums_no), Rezervaciju_skaits DESC;

--Atskaite, kas parāda viesa informāciju par rezervācijas datumu, reģistrācijas datumu, izrakstīšanās datumu un rezervācijas skaitu
SELECT
  Viesis.Vards,
  Viesis.Uzvards,
  Rezervacija.Datums_no AS Rezervācijas_datums,
  Registracija.Datums AS Reģistrēšanās,
  Rezervacija.Datums_lidz AS Izrakstīšanās,
  ROW_NUMBER() OVER (PARTITION BY Viesis.ViesaID ORDER BY Rezervacija.Datums_no) AS Rezervāciju_skaits
FROM
  Viesis
JOIN
  Rezervacija ON Viesis.ViesaID = Rezervacija.ViesaID
JOIN
  Registracija ON Viesis.ViesaID = Registracija.ViesaID AND Rezervacija.NumuraID = Registracija.NumuraID;

-- Atskaite, kas parada visus numurus un to rezervaciju skaitu, kas ir veiktas pašlaik aktīvajā mēnesī
SELECT N.Nosaukums AS Numura_nosaukums, COUNT(R.RezervacijasID) AS Rezervaciju_skaits
FROM Numurs N
LEFT JOIN Rezervacija R ON N.NumuraID = R.NumuraID
WHERE MONTH(R.Datums_no) = MONTH(GETDATE()) OR MONTH(R.Datums_lidz) = MONTH(GETDATE())
GROUP BY N.Nosaukums;

-- Pārskats par katra numura veida vidējo cenu kopā ar kopējo rezervāciju skaitu katram numura veidam
SELECT Numurs.Tips, AVG(Numurs.Cena) AS Vidēja_cena, COUNT(Rezervacija.RezervacijasID) AS Rezervāciju_skaits
FROM Numurs
JOIN Rezervacija ON Numurs.NumuraID = Rezervacija.NumuraID
GROUP BY Numurs.Tips
ORDER BY Rezervāciju_skaits DESC;

-- Kopējie ienākumi, kas gūti no katra pakalpojuma veida, kopā ar katra pakalpojuma izmantošanas reižu skaitu
SELECT PV.Nosaukums AS Pakalpojuma_veids, COUNT(*) AS Pakalpojumu_izmantošanas_skaits, SUM(P.Cena) AS Kopējie_ienākumi
FROM Pakalpojums AS P
JOIN PakalpojumaVeids AS PV ON P.PakalpojumaVeidsID = PV.PakalpojumaVeidsID
JOIN Pakalpojumu_izvele AS PI ON P.PakalpojumaID = PI.PakalpojumaID
GROUP BY PV.Nosaukums
ORDER BY Pakalpojumu_izmantošanas_skaits DESC;

-- Atskaites, kas parāda vidējo rezervāciju ilgumu (dienu skaitu) pēc numura veida.
SELECT N.Tips, AVG(DATEDIFF(DAY, R.Datums_no, R.Datums_lidz)) AS Vidējais_ilgums
FROM Numurs AS N
INNER JOIN Rezervacija AS R ON N.NumuraID = R.NumuraID
GROUP BY N.Tips;

-- Iegūstiet informāciju par rezervāciju skaitu, ko veikuši viesi katrā vecuma grupā
SELECT CASE
        WHEN DATEDIFF(YEAR, V.Dzimsanas_datums, GETDATE()) < 18 THEN 'Zem 18'
        WHEN DATEDIFF(YEAR, V.Dzimsanas_datums, GETDATE()) BETWEEN 18 AND 25 THEN '18-25'
        WHEN DATEDIFF(YEAR, V.Dzimsanas_datums, GETDATE()) BETWEEN 26 AND 35 THEN '26-35'
        WHEN DATEDIFF(YEAR, V.Dzimsanas_datums, GETDATE()) BETWEEN 36 AND 50 THEN '36-50'
        ELSE 'Virs 50'
    END AS Vecuma_grupa,
    COUNT(*) AS Rezervaciju_skaits
FROM Viesis AS V
INNER JOIN Rezervacija AS R ON V.ViesaID = R.ViesaID
GROUP BY CASE
        WHEN DATEDIFF(YEAR, V.Dzimsanas_datums, GETDATE()) < 18 THEN 'Zem 18'
        WHEN DATEDIFF(YEAR, V.Dzimsanas_datums, GETDATE()) BETWEEN 18 AND 25 THEN '18-25'
        WHEN DATEDIFF(YEAR, V.Dzimsanas_datums, GETDATE()) BETWEEN 26 AND 35 THEN '26-35'
        WHEN DATEDIFF(YEAR, V.Dzimsanas_datums, GETDATE()) BETWEEN 36 AND 50 THEN '36-50'
        ELSE 'Virs 50'
    END;

-- Atskaite, kas parāda visvairāk izmaksātās rezervācijas katram viesim, ņemot vērā rezervācijas periodu un izmaksāto summu.
SELECT V.Vards, V.Uzvards, R.Datums_no AS Rezervacijas_datums_no, R.Datums_lidz AS Rezervacijas_datums_lidz,
DATEDIFF(DAY, R.Datums_no, R.Datums_lidz) AS Rezervacijas_ilgums, SUM(N.Cena) AS Kopējā_summa
FROM Viesis V
INNER JOIN Rezervacija R ON V.ViesaID = R.ViesaID
INNER JOIN Numurs N ON R.NumuraID = N.NumuraID
GROUP BY V.Vards, V.Uzvards, R.Datums_no, R.Datums_lidz
ORDER BY Kopējā_summa DESC;

-- Iegūt rezervēto numuru skaitu katrā 2023.gada mēnesī:
SELECT
    MONTH(R.Datums_no) AS Menesis,
    COUNT(*) AS Rezervetu_numuru_skaits
FROM Rezervacija AS R
WHERE YEAR(R.Datums_no) = 2023
GROUP BY MONTH(R.Datums_no)
ORDER BY Menesis;
