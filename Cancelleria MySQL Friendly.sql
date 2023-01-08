CREATE DATABASE Cancelleria;
use Cancelleria;

CREATE TABLE Giudice
(
    Cmatr    VARCHAR(5) PRIMARY KEY,
    Nome     VARCHAR(20) NOT NULL,
    Cognome  VARCHAR(20) NOT NULL,
    CFG      CHAR(16)    NOT NULL,
    Dnascita DATETIME    NOT NULL,
    Lnascita VARCHAR(30) NOT NULL
);

CREATE TABLE Cancellieri_login
(
    Cmatr   VARCHAR(5) PRIMARY KEY,
    -- Nome     VARCHAR(20) NOT NULL,
    Cognome VARCHAR(20) NOT NULL,
    Psw     CHAR(16)    NOT NULL
);

CREATE TABLE Giudici_login
(
    Cmatr   VARCHAR(5) PRIMARY KEY,
    -- Nome     VARCHAR(20) NOT NULL,
    Cognome VARCHAR(20)  NOT NULL,
    Psw     VARCHAR(256) NOT NULL
);
CREATE TABLE Aula
(
    Cod        INT AUTO_INCREMENT PRIMARY KEY,
    Nome       VARCHAR(20),
    Ubicazione VARCHAR(30) NOT NULL,
    Matrgiud   VARCHAR(5),
    FOREIGN KEY (Matrgiud) REFERENCES Giudice (Cmatr)
);

CREATE TABLE Materia
(
    Cod         INT AUTO_INCREMENT PRIMARY KEY,
    Descrizione VARCHAR(500) NOT NULL
);

CREATE TABLE Fascicolo
(
    Rgen    INT AUTO_INCREMENT PRIMARY KEY,
    Anno    YEAR    NOT NULL,
    Fase    CHAR(4) NOT NULL DEFAULT 'ISTR',
    Cod_mat INT     NOT NULL,
    CHECK ( Fase = 'ISTR' OR Fase = 'PROC' OR Fase = 'CONC' ), #Per assicurarsi che non si metta una fase che non dovrebbe
    FOREIGN KEY (Cod_mat) REFERENCES Materia (Cod)
);

CREATE TABLE Verbale_udienza
(
    Id_Verbale        INT AUTO_INCREMENT,
    Data              DATETIME      NOT NULL DEFAULT NOW(), -- Il giudice carica il verbale dopo l'udienza
    Giorno_settimana  VARCHAR(3),
    Descrizione       VARCHAR(3000) NOT NULL,
    Matricola_Giudice VARCHAR(5),
    Rgen              INT           NOT NULL,
    Codice_Aula       INT REFERENCES aula (cod),
    PRIMARY KEY (Id_Verbale, Rgen),
    FOREIGN KEY (Matricola_Giudice) REFERENCES Giudice (Cmatr),
    FOREIGN KEY (Rgen) REFERENCES Fascicolo (Rgen)
);

CREATE TABLE Pgiuridica
(
    PIva            CHAR(11) PRIMARY KEY,
    Tipo_azienda    VARCHAR(500) NOT NULL,
    Ragione_sociale VARCHAR(500) NOT NULL,
    Rapplegale      VARCHAR(50)  NOT NULL
);


CREATE TABLE Pfisica
(
    CF        CHAR(16) PRIMARY KEY,
    Nome      VARCHAR(20) NOT NULL,
    Cognome   VARCHAR(20) NOT NULL,
    Dnascita  DATETIME    NOT NULL,
    Lnascita  VARCHAR(30) NOT NULL,
    Residenza VARCHAR(30) NOT NULL,
    Ruolo     CHAR(3)     NOT NULL DEFAULT 'PRO',
    CHECK ( Ruolo = 'ONO' OR Ruolo = 'TES' OR Ruolo = 'PRO') #PRO indica che è coinvolto nel processo come citato o convenuto
);

CREATE TABLE Avvocato
(
    CF      CHAR(16) PRIMARY KEY,
    Nome    VARCHAR(20) NOT NULL,
    Cognome VARCHAR(20) NOT NULL
);

CREATE TABLE Niscrruolo
(
    Id_nota    INT AUTO_INCREMENT PRIMARY KEY,
    Valore     FLOAT NOT NULL,
    Cunico     FLOAT,
    Codmateria INT,
    FOREIGN KEY (Codmateria) REFERENCES Materia (Cod)
);

CREATE TABLE Depteste
(
    Id_deposizione INT AUTO_INCREMENT PRIMARY KEY,
    Dpres          DATETIME NOT NULL DEFAULT NOW(),
    Nprogr         INT               DEFAULT 0, -- Per evitare campi nulli, poi verrà calcolato opportunamente quando  e se la si assocerà
    CFTest         CHAR(16),
    CFAvv          CHAR(16),
    CFGiud         CHAR(16),
    FOREIGN KEY (CFTest) REFERENCES Pfisica (CF),
    FOREIGN KEY (CFAvv) REFERENCES Avvocato (CF),
    FOREIGN KEY (CFGiud) REFERENCES Pfisica (CF)
);


CREATE TABLE Prova_documentale
(
    Id_prova INT AUTO_INCREMENT PRIMARY KEY,
    Tipo     VARCHAR(5) NOT NULL,
    Dpres    DATETIME   NOT NULL DEFAULT NOW(),
    Nprog    INT        NOT NULL DEFAULT 0, -- Per evitare campi nulli, poi verrà calcolato opportunamente quando  e se la si assocerà
    CFAvv    CHAR(16),
    FOREIGN KEY (CFAvv) REFERENCES Avvocato (CF)
);

CREATE TABLE Attocit
(
    Id_atto INT AUTO_INCREMENT,
    Dpres   DATETIME NOT NULL DEFAULT NOW(),
    Id_nota INT      NOT NULL,
    Rgen    INT      NOT NULL,
    PRIMARY KEY (Id_atto, Rgen),
    FOREIGN KEY (Id_nota) REFERENCES Niscrruolo (Id_nota),
    FOREIGN KEY (Rgen) REFERENCES Fascicolo (Rgen)
);

CREATE TABLE Compconcl
(
    Id_cconcl   INT AUTO_INCREMENT,
    Rgen        INT           NOT NULL,
    Descrizione VARCHAR(3000) NOT NULL,
    DPres       DATETIME      NOT NULL DEFAULT NOW(),
    PRIMARY KEY (Id_cconcl, Rgen),
    FOREIGN KEY (Rgen) REFERENCES Fascicolo (Rgen)
);

CREATE TABLE Sentenza
(
    Id_sentenza INT AUTO_INCREMENT,
    Dpres       DATETIME      NOT NULL DEFAULT NOW(),
    Tipologia   VARCHAR(30)   NOT NULL,
    Bgiur       VARCHAR(3000) NOT NULL,
    Ammenda     FLOAT         NOT NULL,
    Rgen        INT,
    Cmatr       CHAR(5),
    UNIQUE (Rgen, Cmatr),
    PRIMARY KEY (Id_sentenza, Rgen),
    FOREIGN KEY (Cmatr) REFERENCES Giudice (Cmatr),
    FOREIGN KEY (Rgen) REFERENCES Fascicolo (Rgen)
);

CREATE TABLE Memoria186
(
    Id_mem      INT AUTO_INCREMENT,
    RGen        INT           NOT NULL,
    Dpres       DATETIME      NOT NULL DEFAULT NOW(),
    Tipo        INT           NOT NULL,
    Domande     VARCHAR(3000) NOT NULL,
    Eccezioni   VARCHAR(3000) NOT NULL,
    Conclusioni VARCHAR(3000) NOT NULL,
    PRIMARY KEY (Id_mem, RGen),
    FOREIGN KEY (RGen) REFERENCES Fascicolo (Rgen),
    CHECK ( Tipo = 1 OR Tipo = 2 OR Tipo = 3 ) #Per assicurarsi che non si metta un tipo che non dovrebbe
);
CREATE TABLE Include
(
    Idverb INT,
    CFavv  CHAR(16),
    PRIMARY KEY (Idverb, CFavv),
    FOREIGN KEY (Idverb) REFERENCES Verbale_udienza (Id_Verbale),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF)
);

CREATE TABLE PresenteVPF
(
    Idverb INT,
    CFpf   CHAR(16) NOT NULL,
    PRIMARY KEY (Idverb, CFpf),
    FOREIGN KEY (Idverb) REFERENCES Verbale_udienza (Id_Verbale),
    FOREIGN KEY (CFpf) REFERENCES Pfisica (CF)
);

CREATE TABLE PresenteVPG
(
    Idverb INT,
    Piva   CHAR(11),
    PRIMARY KEY (Idverb, Piva),
    FOREIGN KEY (Idverb) REFERENCES Verbale_udienza (Id_Verbale),
    FOREIGN KEY (Piva) REFERENCES Pgiuridica (PIva)
);

CREATE TABLE Presenta
(
    CFavv    CHAR(16) NOT NULL,
    Idcconcl INT,
    PRIMARY KEY (CFavv, Idcconcl),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF),
    FOREIGN KEY (Idcconcl) REFERENCES Compconcl (Id_cconcl)
);

CREATE TABLE ComponeAD
(
    Iddep  INT NOT NULL,
    Idatto INT NOT NULL,
    PRIMARY KEY (Iddep, Idatto),
    FOREIGN KEY (Iddep) REFERENCES Depteste (Id_deposizione),
    FOREIGN KEY (Idatto) REFERENCES Attocit (Id_atto)
);

CREATE TABLE ComponeAP
(
    Idprova INT NOT NULL,
    Idatto  INT NOT NULL,
    PRIMARY KEY (Idprova, Idatto),
    FOREIGN KEY (Idprova) REFERENCES Prova_documentale (Id_prova),
    FOREIGN KEY (Idatto) REFERENCES Attocit (Id_atto)
);

CREATE TABLE Cita
(
    CFpf   CHAR(16),#CHAR(16),
    CFavv  CHAR(16),#CHAR(16),
    Idatto INT,
    PRIMARY KEY (CFpf, CFavv, Idatto),
    FOREIGN KEY (CFpf) REFERENCES Pfisica (CF),
    FOREIGN KEY (Idatto) REFERENCES Attocit (Id_atto),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF)
);

CREATE TABLE Citato
(
    CFpf   CHAR(16),#CHAR(16),
    CFavv  CHAR(16),#CHAR(16),
    Idatto INT,
    PRIMARY KEY (CFpf, CFavv, Idatto),
    FOREIGN KEY (CFpf) REFERENCES Pfisica (CF),
    FOREIGN KEY (Idatto) REFERENCES Attocit (Id_atto),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF)
);

CREATE TABLE CitaPG
(
    Piva   CHAR(11),
    Idatto INT,
    CFavv  CHAR(16),#CHAR(16),
    PRIMARY KEY (Piva, CFavv, Idatto),
    FOREIGN KEY (Piva) REFERENCES Pgiuridica (PIva),
    FOREIGN KEY (Idatto) REFERENCES Attocit (Id_atto),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF)
);

CREATE TABLE CitatoPG
(
    Piva   CHAR(11),
    Idatto INT,
    CFavv  CHAR(16),#CHAR(16),
    PRIMARY KEY (Piva, CFavv, Idatto),
    FOREIGN KEY (Piva) REFERENCES Pgiuridica (PIva),
    FOREIGN KEY (Idatto) REFERENCES Attocit (Id_atto),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF)
);

/*CREATE TABLE PresentaAA
(
    CFavv  CHAR(16),
    Idatto INT,
    PRIMARY KEY (CFavv, Idatto),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF),
    FOREIGN KEY (Idatto) REFERENCES Attocit (Id_atto)
);*/

CREATE TABLE Accede
(
    Codmatr CHAR(5),
    R_gen   INT,
    PRIMARY KEY (Codmatr, R_gen),
    FOREIGN KEY (Codmatr) REFERENCES Giudice (Cmatr),
    FOREIGN KEY (R_gen) REFERENCES Fascicolo (Rgen)
);

CREATE TABLE Rientra
(
    CFavv   CHAR(16),
    R_gen   INT,
    Fazione CHAR(3),
    PRIMARY KEY (CFavv, R_gen),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF),
    FOREIGN KEY (R_gen) REFERENCES Fascicolo (Rgen),
    CHECK ( Fazione = 'ACC' OR Fazione = 'DIF')
);

CREATE TABLE RientraFPF
(
    CFPF  CHAR(16),
    R_gen INT,
    PRIMARY KEY (CFPF, R_gen),
    FOREIGN KEY (CFPF) REFERENCES Pfisica (CF),
    FOREIGN KEY (R_gen) REFERENCES Fascicolo (Rgen)
);

CREATE TABLE RientraFPG
(
    Piva  CHAR(16),
    R_gen INT,
    PRIMARY KEY (Piva, R_gen),
    FOREIGN KEY (Piva) REFERENCES Pgiuridica (Piva),
    FOREIGN KEY (R_gen) REFERENCES Fascicolo (Rgen)
);

CREATE TABLE ContieneMD
(
    Idmem INT,
    Iddep INT,
    PRIMARY KEY (Idmem, Iddep),
    FOREIGN KEY (Idmem) REFERENCES Memoria186 (Id_mem),
    FOREIGN KEY (Iddep) REFERENCES Depteste (Id_deposizione)
);

CREATE TABLE ContieneMP
(
    Idmem   INT NOT NULL,
    Idprova INT NOT NULL,
    PRIMARY KEY (Idmem, Idprova),
    FOREIGN KEY (Idmem) REFERENCES Memoria186 (Id_mem),
    FOREIGN KEY (Idprova) REFERENCES Prova_documentale (Id_prova)
);

CREATE TABLE PresentaAM
(
    Idmem INT,
    CFavv CHAR(16),
    PRIMARY KEY (Idmem, CFavv),
    FOREIGN KEY (Idmem) REFERENCES Memoria186 (Id_mem),
    FOREIGN KEY (CFavv) REFERENCES Avvocato (CF)
);


#                                                                                         #
#---------- Trigger per l'aggiornamento del numero progressivo di prove e teste ----------#
#                                                                                         #
DELIMITER @@
CREATE TRIGGER Upnumprogprove_damemorie
    BEFORE INSERT
    ON ContieneMP
    FOR EACH ROW
BEGIN
    DECLARE Fascicolo, Atto, provemem, proveatto INT;
    IF ((SELECT tipo FROM memoria186 WHERE Id_mem = NEW.Idmem) <> 3)
    THEN
        signal sqlstate '45000' SET MESSAGE_TEXT = 'Si sta tentando di associare una Memoria che non è la terza';
    END IF;
    SELECT RGen
    FROM Memoria186
    WHERE (Memoria186.Id_mem = NEW.Idmem AND Memoria186.Tipo = 3)
    INTO Fascicolo; #Estraggo il Registro Generale che identifichi il fascicolo
    SELECT COUNT(Idmem)
    FROM ContieneMP
    WHERE Idmem = NEW.Idmem
    INTO provemem; #Estraggo il numero di prove per la memoria186 n°3 (Una per Fascicolo)
    SELECT Id_atto
    FROM Attocit
    WHERE Rgen = Fascicolo
    INTO Atto; #Estraggo codice atto per ottenere numero prove per atto di cit. (uno per fascicolo)
    SELECT COUNT(Idatto) FROM ComponeAP WHERE Idatto = Atto INTO proveatto; #Conto le prove dell'atto
    UPDATE Prova_documentale
    SET Nprog=(provemem + proveatto + 1)
    WHERE Id_prova = NEW.Idprova; #Faccio l'update della prova
END;
@@
DELIMITER ;
DELIMITER @@
CREATE TRIGGER Upnumprogprove_daatto
    BEFORE INSERT
    ON ComponeAP
    FOR EACH ROW
BEGIN
    #Analogo a quanto fatto nel trigger "Upnumprogprove_damemorie" però iniziando dall'atto
    DECLARE Memoria, Fascicolo, provemem, proveatto INT;
    SELECT COUNT(Idatto) FROM ComponeAP WHERE Idatto = NEW.Idatto INTO proveatto;
    SELECT RGen FROM Attocit WHERE Id_atto = NEW.Idatto INTO Fascicolo;
    SELECT Id_mem FROM Memoria186 WHERE (Rgen = Fascicolo AND Memoria186.Tipo = 3) INTO Memoria;
    SELECT COUNT(Idmem) FROM ContieneMP WHERE Idmem = Memoria INTO provemem;
    UPDATE Prova_documentale SET Nprog=(provemem + proveatto + 1) WHERE Id_prova = NEW.Idprova;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Upnumprogteste_damemorie
    BEFORE INSERT
    ON ContieneMD
    FOR EACH ROW
BEGIN
    DECLARE Fascicolo, Atto, depoisizionimem, deposizioniatto INT;
    #Verifico di star associando memoria di tipo 3
    IF ((SELECT tipo FROM memoria186 WHERE Id_mem = NEW.Idmem) <> 3)
    THEN
        signal sqlstate '45000' SET MESSAGE_TEXT = 'Si sta tentando di associare una Memoria che non è la terza';
    END IF;
    SELECT COUNT(Idmem)
    FROM ContieneMD
    WHERE ContieneMD.Idmem = NEW.Idmem
    INTO depoisizionimem; #Estraggo il numero di teste per la memoria186 n°3 (Una per Fascicolo)
    SELECT RGen
    FROM Memoria186
    WHERE (Memoria186.Id_mem = NEW.Idmem AND Tipo = 3)
    INTO Fascicolo; #Estraggo il Registro Generale che identifichi il fascicolo
    SELECT Id_atto
    FROM Attocit
    WHERE Rgen = Fascicolo
    INTO Atto; #Estraggo codice atto per ottenere numero teste per atto di cit. (uno per fascicolo)
    SELECT COUNT(Idatto) FROM ComponeAD WHERE Idatto = Atto INTO deposizioniatto; #Conto i teste dell'atto
    UPDATE Depteste
    SET Nprogr=(deposizioniatto + depoisizionimem + 1)
    WHERE Depteste.Id_deposizione = NEW.Iddep; #Faccio l'update del teste
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Upnumprogteste_daatto
    BEFORE INSERT
    ON ComponeAD
    FOR EACH ROW
BEGIN
    #Analogo a quanto fatto nel trigger "Upnumprogteste_damemorie" però iniziando dall'atto
    DECLARE Memoria, Fascicolo, deposizionimem, deposizioniatto INT;
    SELECT COUNT(Idatto) FROM ComponeAD WHERE Idatto = new.Idatto INTO deposizioniatto;
    SELECT RGen FROM Attocit WHERE Id_atto = NEW.Idatto INTO Fascicolo;
    SELECT Id_mem FROM Memoria186 WHERE (Rgen = Fascicolo AND Memoria186.Tipo = 3) INTO Memoria;
    SELECT COUNT(Idmem) FROM ContieneMD WHERE Idmem = Memoria INTO deposizionimem;
    UPDATE Depteste SET Nprogr=(deposizionimem + deposizioniatto + 1) WHERE Depteste.Id_deposizione = NEW.Iddep;
END;
@@
DELIMITER ;

#                                                                                  #
#---------- Procedure per inserimento associazione Mem-Teste / Mem-Prova ----------#
#                                                                                  #
DELIMITER @@
CREATE PROCEDURE Associamemoriaprova(IN Memoria INT, IN Prova INT)
BEGIN
    IF ((SELECT COUNT(Id_mem) FROM Memoria186 WHERE Id_mem = Memoria) = 0)
    THEN
        signal sqlstate '45000' set message_text = 'Codice Memoria inesistente';
    ELSEIF ((SELECT COUNT(Id_prova) FROM Prova_documentale WHERE Id_prova = Prova) = 0)
    THEN
        signal sqlstate '45000' SET MESSAGE_TEXT = 'Codice Prova inesistente';
    ELSEIF (SELECT tipo FROM Memoria186 WHERE Id_mem = Memoria <> 3)
    THEN
        signal sqlstate '45000' SET MESSAGE_TEXT = 'Si sta tentando di associare una Memoria che non è la terza';
    ELSE
        START TRANSACTION;
        INSERT INTO ContieneMP VALUES (Idmem = Memoria, Idprova = Prova);
        COMMIT;
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@

CREATE PROCEDURE Associamemoriateste(IN Memoria INT, IN Teste INT)
BEGIN
    IF ((SELECT COUNT(Id_mem) FROM Memoria186 WHERE Id_mem = Memoria) = 0)
    THEN
        signal sqlstate '45000' set message_text = 'Codice Memoria inesistente';
    ELSEIF ((SELECT COUNT(Id_deposizione) FROM Depteste WHERE Id_deposizione = Teste) = 0)
    THEN
        signal sqlstate '45000' SET MESSAGE_TEXT = 'Codice Teste inesistente';
    ELSEIF (SELECT tipo FROM Memoria186 WHERE Id_mem = Memoria <> 3)
    THEN
        signal sqlstate '45000' SET MESSAGE_TEXT = 'Si sta tentando di associare una Memoria che non è la terza';
    ELSE
        START TRANSACTION;
        INSERT INTO ContieneMD VALUES (Idmem = Memoria, Iddep = Teste);
        COMMIT;
    END IF;
END;
@@
DELIMITER ;

#                                                         #
#---------- Procedure per dare il nome all'aula ----------#
#                                                         #
DELIMITER @@
CREATE TRIGGER NominaAula
    BEFORE INSERT
    ON Aula
    FOR EACH ROW
BEGIN
    DECLARE codaula INT;DECLARE nomegiud VARCHAR(20);
    SELECT Cognome FROM Giudice WHERE Cmatr = NEW.Matrgiud INTO nomegiud;
    SET NEW.Nome = nomegiud;
END;
@@
DELIMITER ;
DELIMITER @@
CREATE TRIGGER logingiudici
    AFTER INSERT
    ON Giudice
    FOR EACH ROW
BEGIN
    IF (NOT EXISTS(SELECT Cmatr FROM Giudici_login WHERE Giudici_login.Cmatr = NEW.Cmatr))
    THEN
        INSERT INTO Giudici_login (Cmatr, Cognome, Psw)
        VALUES (NEW.Cmatr, NEW.Cognome, SHA2(concat(NEW.Cmatr, '1234!'), '256'));
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@

CREATE PROCEDURE AggiornaAula(IN Codiceaula INT, IN Giu VARCHAR(5))
BEGIN
    IF ((SELECT COUNT(Cod) FROM Aula WHERE Cod = Codiceaula) = 0)
    THEN
        signal sqlstate '45000' set message_text = 'Aula inesistente';
    ELSEIF ((SELECT COUNT(Cmatr) FROM Giudice WHERE Cmatr = Giu) = 0)
    THEN
        signal sqlstate '45000' set message_text = 'Giudice inesistente';
    ELSE
        START TRANSACTION;
        UPDATE Aula SET Matrgiud=Giu, Nome=(SELECT Nome FROM Giudice WHERE Cmatr = Giu) WHERE Cod = Codiceaula;
        COMMIT;
    END IF;
END;
@@
DELIMITER ;

#                                               #
#---------- Trigger prende e rilascia ----------#
#                                               #

/*CREATE TRIGGER ControllaOnorario
    AFTER INSERT
    ON Depteste
    FOR EACH ROW
BEGIN
    DECLARE Coddep INT;
    DECLARE CFtestimone,CFgiudice CHAR(16);
    SELECT Id_deposizione FROM Depteste WHERE Dpres = (SELECT MAX(Dpres) FROM Depteste) INTO Coddep;
    SELECT CFGiud FROM Depteste WHERE Id_deposizione = Coddep INTO CFgiudice;
    SELECT CFTest FROM Depteste WHERE Id_deposizione = Coddep INTO CFtestimone;
    IF ((SELECT Ruolo FROM Pfisica WHERE CF = CFgiudice) <> 'ONO' OR
        (SELECT Ruolo FROM Pfisica WHERE CF = CFtestimone) <> 'TES')
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Si sta cercando di associare un giudice che non lo è o un testimone che non lo è';
    END IF;
END;*/

DELIMITER @@
CREATE TRIGGER ControllaOnorario
    BEFORE INSERT
    ON Depteste
    FOR EACH ROW
BEGIN
    IF ((SELECT Ruolo FROM Pfisica WHERE CF = NEW.CFGiud) <> 'ONO')
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Si sta cercando di associare una persona fisica che non è un giudice in CFGiud';
    ELSEIF ((SELECT Ruolo FROM Pfisica WHERE CF = NEW.CFTest) <> 'TES')
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Si sta cercando di associare una persona fisica che non è un Testimone in CFTest';
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Upfase_proc
    BEFORE INSERT
    ON verbale_udienza
    FOR EACH ROW
BEGIN
    /*DECLARE Fasc INT;
    SELECT Rgen
    FROM verbale_udienza
    WHERE Verbale_udienza.Data = (SELECT MAX(Verbale_udienza.Data) FROM Verbale_udienza)
    INTO Fasc;
    IF ((SELECT Fase FROM Fascicolo WHERE Rgen = fasc) = 'CONC')
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Il fascicolo risulta già concluso!';
    ELSE
        UPDATE Fascicolo SET Fase='PROC' WHERE Rgen = Fasc;
    END IF;*/
    IF ((SELECT Fase FROM Fascicolo WHERE Fascicolo.Rgen = NEW.Rgen) = 'ISTR')
    THEN
        UPDATE Fascicolo SET Fase='PROC' WHERE Rgen = NEW.Rgen;
    ELSEIF ((SELECT Fase FROM Fascicolo WHERE Rgen = NEW.Rgen) = 'CONC')
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Il fascicolo risulta già concluso!';
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Upfase_conc
    AFTER INSERT
    ON verbale_udienza
    FOR EACH ROW
BEGIN
    DECLARE Fasc INT;
    -- SELECT Rgen FROM sentenza WHERE Dpres = (SELECT MAX(Dpres) FROM sentenza) INTO Fasc;
    IF ((SELECT Fase FROM Fascicolo WHERE Rgen = NEW.Rgen) = 'CONC')
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Il fascicolo risulta già concluso!';
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Aggiornacontr
    BEFORE INSERT
    ON niscrruolo
    FOR EACH ROW
BEGIN
    -- DECLARE nota INT;
    -- DECLARE val FLOAT;
    -- SELECT Id_nota FROM niscrruolo WHERE Id_nota = (SELECT MAX(Id_nota) FROM niscrruolo) INTO nota;
    -- SELECT Valore FROM niscrruolo WHERE Id_nota = nota INTO val;
    IF (NEW.Valore <= 15000)
    THEN
        SET NEW.Cunico = NEW.Valore * 0.23;
    ELSEiF (NEW.Valore <= 28000)
    THEN
        SET NEW.Cunico = NEW.Valore * 0.25;
    ELSEIF (NEW.Valore <= 50000)
    THEN
        SET NEW.Cunico = NEW.Valore * 0.35;
    ELSE
        SET NEW.Cunico = NEW.Valore * 0.43;
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Aggiornacontr_UP
    BEFORE UPDATE
    ON niscrruolo
    FOR EACH ROW
BEGIN
    -- DECLARE nota INT;d
    -- DECLARE val FLOAT;
    -- SELECT Id_nota FROM niscrruolo WHERE Id_nota = (SELECT MAX(Id_nota) FROM niscrruolo) INTO nota;
    -- SELECT Valore FROM niscrruolo WHERE Id_nota = nota INTO val;
    IF (NEW.Valore <= 15000)
    THEN
        SET NEW.Cunico = NEW.Valore * 0.23;
    ELSEiF (NEW.Valore <= 28000)
    THEN
        SET NEW.Cunico = NEW.Valore * 0.25;
    ELSEIF (NEW.Valore <= 50000)
    THEN
        SET NEW.Cunico = NEW.Valore * 0.35;
    ELSE
        SET NEW.Cunico = NEW.Valore * 0.43;
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Checkdatacomparsa
    BEFORE INSERT
    ON Compconcl
    FOR EACH ROW
BEGIN
    DECLARE Atto, Memoria DATETIME;
    /* Si ottiene la tabella con le memorie (e relative date) del fascicolo interessato dalla comparsa
       e si seleziona l'ultima in ordine di tempo*/
    SELECT MAX(Dpres) FROM Memoria186 WHERE RGen = NEW.Rgen INTO Memoria;

    SELECT Dpres FROM attocit WHERE Attocit.Rgen = NEW.Rgen INTO Atto;
    IF (Atto > NEW.DPres OR Memoria > NEW.DPres)
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'La data della comparsa deve essere successiva alla data degli altri atti del fascicolo!';
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER CheckdateMemori_NonpervenutiMem3
    BEFORE INSERT
    ON Memoria186
    FOR EACH ROW
BEGIN
    DECLARE Data_atto DATETIME;
    DECLARE mempresenti INT;
    SELECT Dpres FROM attocit WHERE Attocit.Rgen = NEW.RGen INTO Data_atto;
    SELECT Count(Rgen) FROM Memoria186 WHERE RGen = NEW.RGen INTO mempresenti;
    IF (NEW.Tipo = 1)
    THEN
        IF (mempresenti > 0)
        THEN
            SET @errstring = CONCAT('Sono già presenti per il fascicolo ', NEW.RGen, ' memorie. Usare tipo 2 o 3');
            SIGNAL sqlstate '45001' set message_text = @errstring;
        ELSEIF ((SELECT DATEDIFF(NEW.Dpres, Data_atto)) < 30)
        THEN
            SET @errstring = 'Almeno 30 giorni tra la Memoria e l\'Atto di citazione';
            SIGNAL sqlstate '45001' set message_text = @errstring;
        END IF;
    ELSEIF (NEW.Tipo = 2)
    THEN
        IF (mempresenti >= 2)
        THEN
            SET @errstring = CONCAT('Sono già presenti per il fascicolo ', NEW.RGen,
                                    ' almeno due memorie, usare tipo 3 o cambiare Rgen');
            SIGNAL sqlstate '45001' set message_text = @errstring;
        ELSEIF (mempresenti < 1)
        THEN
            SET @errstring = CONCAT('Non è presente alcuna memoria, tipo "2" non consentito');
            SIGNAL sqlstate '45001' set message_text = @errstring;
        ELSEIF ((SELECT DATEDIFF(NEW.Dpres, (SELECT Dpres FROM Memoria186 WHERE RGen = NEW.RGen))) < 30)
        THEN
            SET @errstring =
                    CONCAT('Intervallo di date tra Memoria 2 e 1 non congruente. Deve essere di almeno 30 giorni');
            SIGNAL sqlstate '45001' set message_text = @errstring;
        END IF;
    ELSEIF (mempresenti = 3)
    THEN
        SET @errstring = CONCAT('Sono già presenti per il fascicolo ', NEW.RGen, ' 3 memorie');
        SIGNAL sqlstate '45001' set message_text = @errstring;
    ELSEIF (mempresenti < 2)
    THEN
        SET @errstring = CONCAT('Non è presente Memoria di tipo "2", tipo "3" non consentito');
        SIGNAL sqlstate '45001' set message_text = @errstring;
    ELSEIF ((SELECT DATEDIFF(NEW.Dpres, (SELECT MAX(Dpres) FROM Memoria186 WHERE RGen = NEW.RGen))) < 20)
    THEN
        SET @errstring = CONCAT('Intervallo di date tra Memoria 3 e 2 non congruente. Deve essere di almeno 20 giorni');
        SIGNAL sqlstate '45001' set message_text = @errstring;
    END IF;

    -- Rettifica Conclusioni, Domande ed Eccezioni per la memoria 3
    IF (NEW.Tipo = 3)
    THEN
        SET NEW.Domande = 'Tipologia non interessata dal tipo di Memoria';
        SET NEW.Eccezioni = 'Tipologia non interessata dal tipo di Memoria';
        SET NEW.Conclusioni = 'Tipologia non interessata dal tipo di Memoria';
    end if;
END;
@@
DELIMITER ;


DELIMITER @@
CREATE TRIGGER Checkpresentazionememorie
    BEFORE INSERT
    ON PresentaAM
    FOR EACH ROW
BEGIN
    DECLARE regmem INT;
/*DECLARE t1 INT;
end;
    IF ((SELECT Tipo FROM Memoria186 WHERE Id_mem = NEW.Idmem) = 2)
    THEN
        SELECT Id_mem FROM Memoria186 WHERE RGen = (SELECT Rgen FROM Memoria186 WHERE Id_mem = NEW.Idmem) INTO t1;
        IF ((SELECT Count(CFavv) FROM PresentaAM WHERE Idmem = t1 AND CFavv = NEW.CFavv) > 0)
        THEN
            SIGNAL sqlstate '45001' set message_text =
                    'Si sta cercando di associare una memoria di tipo 2 presentata da un avvocato che ha presentato quella di tipo 1';
        END IF;
    end if;*/

    SELECT Rgen FROM Memoria186 WHERE Id_mem = NEW.Idmem INTO regmem;
    IF ((SELECT Tipo FROM Memoria186 WHERE Id_mem = NEW.Idmem) = 2)
    THEN
        IF (NOT EXISTS(SELECT Rientra.CFavv
                       FROM Rientra
                       WHERE (Rientra.R_gen = regmem AND Rientra.CFavv = NEW.CFavv)))
        THEN
            SIGNAL sqlstate '45001' set message_text =
                    'L\'avvocato non è associato al fascicolo';
        ELSEIF (SELECT CFavv FROM Rientra WHERE (R_gen = regmem AND Rientra.CFavv = NEW.CFavv AND Fazione = 'ACC'))
        THEN
            SIGNAL sqlstate '45001' set message_text =
                    'L\'avvocato è dell\'accusa: deve essere della difesa nel tipo 2';
        END IF;
    END IF;

    IF ((SELECT Tipo FROM Memoria186 WHERE Id_mem = NEW.Idmem) = 1)
    THEN
        IF (SELECT CFavv FROM Rientra WHERE (R_gen = regmem AND Rientra.CFavv = NEW.CFavv AND Fazione = 'DIF'))
        THEN
            SIGNAL sqlstate '45001' set message_text =
                    'L\'avvocato è della difesa: deve essere dell\'accusa nel tipo 1';
        END IF;
    end if;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER CheckpresentazioniAVVcompconcl
    BEFORE INSERT
    ON Presenta
    FOR EACH ROW
BEGIN
    DECLARE regcconcl INT;
    SELECT Rgen FROM Compconcl WHERE Compconcl.Id_cconcl = NEW.Idcconcl INTO regcconcl;
    IF (NOT EXISTS(SELECT Rientra.CFavv
                   FROM Rientra
                   WHERE (Rientra.R_gen = regcconcl AND Rientra.CFavv = NEW.CFavv)))
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'L\'avvocato non è associato al fascicolo';
    END IF;
END;
@@
DELIMITER ;


DELIMITER @@
CREATE TRIGGER Giornosetudienza
    BEFORE INSERT
    ON Verbale_udienza
    FOR EACH ROW
BEGIN
    DECLARE giorno INT;
    SELECT weekday(NEW.Data) INTO giorno;
    CASE giorno
        WHEN 0 THEN SET NEW.Giorno_settimana = 'LUN';
        WHEN 1 THEN SET NEW.Giorno_settimana = 'MAR';
        WHEN 2 THEN SET NEW.Giorno_settimana = 'MER';
        WHEN 3 THEN SET NEW.Giorno_settimana = 'GIO';
        WHEN 4 THEN SET NEW.Giorno_settimana = 'VEN';
        END CASE;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Assegnaaula
    BEFORE INSERT
    ON verbale_udienza
    FOR EACH ROW
BEGIN
    DECLARE codice INT;
        (SELECT Cod FROM Aula WHERE Matrgiud = NEW.Matricola_Giudice) INTO codice;
    SET NEW.Codice_Aula = codice;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Check_citacitatoPF
    BEFORE INSERT
    ON Cita
    FOR EACH ROW
BEGIN
    IF (EXISTS(SELECT CFpf FROM Citato WHERE (Citato.Idatto = NEW.Idatto AND Citato.CFpf = NEW.CFpf)))
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Una persona non può citare ed essere citata';
    ELSEIF ((SELECT Ruolo FROM Pfisica WHERE Pfisica.CF = NEW.CFpf) <> 'PRO')
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Onorari e testimoni non citano';
    END IF;

    IF ((EXISTS(SELECT CFavv FROM CitatoPG WHERE (CitatoPG.Idatto = NEW.Idatto AND CitatoPG.CFavv = NEW.CFavv)) OR
         EXISTS(SELECT CFavv FROM Citato WHERE Citato.Idatto = NEW.Idatto AND Citato.CFavv = NEW.CFavv)))
    THEN
        BEGIN
            SIGNAL sqlstate '45001' set message_text =
                    'Un avvocato non può essere in accusa e difesa allo stesso momento';
        end;
    END IF;

    IF (NOT EXISTS(SELECT Citato.CFavv, CitatoPG.CFavv, CitaPG.CFavv
                   FROM Citato,
                        CitatoPG,
                        CitaPG
                   WHERE (Citato.CFavv = CitatoPG.CFavv AND CitatoPG.CFavv = CitaPG.CFavv AND
                          CitaPG.CFavv = NEW.CFavv)
                     AND (Citato.Idatto = CitatoPG.Idatto AND CitatoPG.Idatto = CitaPG.Idatto AND
                          CitaPG.Idatto = NEW.Idatto)) AND
        NOT EXISTS(SELECT CFAvv, R_gen
                   FROM Rientra
                   WHERE Rientra.CFavv = NEW.CFavv
                     AND R_gen = (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto)))
    THEN
        INSERT INTO Rientra (CFavv, R_gen, Fazione)
        VALUES (NEW.CFavv, (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto), 'ACC');
    END IF;

    INSERT INTO rientrafpf (CFPF, R_gen) values (NEW.CFpf, (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto));
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Check_citatocitaPF
    BEFORE INSERT
    ON Citato
    FOR EACH ROW
BEGIN
    IF (EXISTS(SELECT CFpf FROM Cita WHERE (Cita.Idatto = NEW.Idatto AND Cita.CFpf = NEW.CFpf)))
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Una persona non può citare ed essere citata';
    ELSEIF ((SELECT Ruolo FROM Pfisica WHERE Pfisica.CF = NEW.CFpf) <> 'PRO')
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Onorari e testimoni non possono essere citati';
    END IF;

    IF ((EXISTS(SELECT CFavv FROM CitaPG WHERE (CitaPG.Idatto = NEW.Idatto AND CitaPG.CFavv = NEW.CFavv)) OR
         EXISTS(SELECT CFavv FROM Cita WHERE Cita.Idatto = NEW.Idatto AND Cita.CFavv = NEW.CFavv)))
    THEN
        BEGIN
            SIGNAL sqlstate '45001' set message_text =
                    'Un avvocato non può essere in accusa e difesa allo stesso momento';
        end;
    END IF;

    IF (NOT EXISTS(SELECT Cita.CFavv, CitatoPG.CFavv, CitaPG.CFavv
                   FROM Cita,
                        CitatoPG,
                        CitaPG
                   WHERE (Cita.CFavv = CitatoPG.CFavv AND CitatoPG.CFavv = CitaPG.CFavv AND
                          CitaPG.CFavv = NEW.CFavv)
                     AND (Cita.Idatto = CitatoPG.Idatto AND CitatoPG.Idatto = CitaPG.Idatto AND
                          CitaPG.Idatto = NEW.Idatto)) AND
        NOT EXISTS(SELECT CFAvv, R_gen
                   FROM Rientra
                   WHERE Rientra.CFavv = NEW.CFavv
                     AND R_gen = (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto)))
    THEN
        INSERT INTO Rientra (CFavv, R_gen, Fazione)
        VALUES (NEW.CFavv, (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto), 'DIF');
    END IF;

    INSERT INTO rientrafpf (CFPF, R_gen) values (NEW.CFpf, (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto));
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Check_citacitatoPG
    BEFORE INSERT
    ON CitaPG
    FOR EACH ROW
BEGIN
    IF (EXISTS(SELECT Piva FROM CitatoPG WHERE (CitatoPG.Idatto = NEW.Idatto AND CitatoPG.Piva = NEW.Piva)))
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Una persona non può citare ed essere citata';
    END IF;

    IF ((EXISTS(SELECT CFavv FROM CitatoPG WHERE (CitatoPG.Idatto = NEW.Idatto AND CitatoPG.CFavv = NEW.CFavv)) OR
         EXISTS(SELECT CFavv FROM Citato WHERE Citato.Idatto = NEW.Idatto AND Citato.CFavv = NEW.CFavv)))
    THEN
        BEGIN
            SIGNAL sqlstate '45001' set message_text =
                    'Un avvocato non può essere in accusa e difesa allo stesso momento';
        end;
    END IF;

    IF (NOT EXISTS(SELECT Citato.CFavv, CitatoPG.CFavv, Cita.CFavv
                   FROM Citato,
                        CitatoPG,
                        Cita
                   WHERE (Citato.CFavv = CitatoPG.CFavv AND CitatoPG.CFavv = Cita.CFavv AND Cita.CFavv = NEW.CFavv)
                     AND (Citato.Idatto = CitatoPG.Idatto AND CitatoPG.Idatto = Cita.Idatto AND
                          Cita.Idatto = NEW.Idatto)) AND
        NOT EXISTS(SELECT CFAvv, R_gen
                   FROM Rientra
                   WHERE Rientra.CFavv = NEW.CFavv
                     AND R_gen = (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto)))
    THEN
        INSERT INTO Rientra (CFavv, R_gen, Fazione)
        VALUES (NEW.CFavv, (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto), 'ACC');
    END IF;

    INSERT INTO rientrafpg (Piva, R_gen) values (NEW.Piva, (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto));
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Check_citatocitaPG
    BEFORE INSERT
    ON CitatoPG
    FOR EACH ROW
BEGIN
    IF (EXISTS(SELECT CitaPG.Piva FROM Citapg WHERE (CitaPG.Idatto = NEW.Idatto AND CitaPG.Piva = NEW.Piva)))
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'Una persona non può citare ed essere citata';
    END IF;

    IF ((EXISTS(SELECT CFavv FROM CitaPG WHERE (CitaPG.Idatto = NEW.Idatto AND CitaPG.CFavv = NEW.CFavv)) OR
         EXISTS(SELECT CFavv FROM Cita WHERE Cita.Idatto = NEW.Idatto AND Cita.CFavv = NEW.CFavv)))
    THEN
        BEGIN
            SIGNAL sqlstate '45001' set message_text =
                    'Un avvocato non può essere in accusa e difesa allo stesso momento';
        end;
    END IF;


    IF (NOT EXISTS(SELECT Citato.CFavv, CitaPG.CFavv, Cita.CFavv
                   FROM Citato,
                        CitaPG,
                        Cita
                   WHERE (Citato.CFavv = CitaPG.CFavv AND CitaPG.CFavv = Cita.CFavv = NEW.CFavv)
                     AND (Citato.Idatto = CitaPG.Idatto = Cita.Idatto = NEW.Idatto)) AND
        NOT EXISTS(SELECT CFAvv, R_gen
                   FROM Rientra
                   WHERE Rientra.CFavv = NEW.CFavv
                     AND R_gen = (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto)))
    THEN
        INSERT INTO Rientra (CFavv, R_gen, Fazione)
        VALUES (NEW.CFavv, (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto), 'DIF');
    END IF;

    INSERT INTO rientrafpg (Piva, R_gen) values (NEW.Piva, (SELECT Rgen FROM Attocit WHERE Id_atto = NEW.Idatto));
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER Checksentgiud
    BEFORE INSERT
    ON Sentenza
    FOR EACH ROW
BEGIN
    IF ((SELECT COUNT(Codmatr) FROM Accede WHERE (Codmatr = NEW.Cmatr AND R_gen = NEW.Rgen)) = 0) THEN
        SIGNAL sqlstate '45001' set message_text =
                'Il giudice che emette la Sentenza deve essere associato al Fascicolo';
    ELSEIF ((SELECT Fase FROM Fascicolo WHERE NEW.Rgen = Fascicolo.Rgen) = 'ISTR') THEN
        SIGNAL sqlstate '45001' set message_text =
                'Ci deve essere stata almeno un\'udienza';
    ELSE
        UPDATE Fascicolo SET Fase='CONC' WHERE Rgen = NEW.Rgen;
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER CheckAvverb
    BEFORE INSERT
    ON Include
    FOR EACH ROW
BEGIN
    DECLARE regcconcl INT;
    SELECT Rgen FROM Verbale_udienza WHERE Verbale_udienza.Id_Verbale = NEW.Idverb INTO regcconcl;
    IF (NOT EXISTS(SELECT Rientra.CFavv
                   FROM Rientra
                   WHERE (Rientra.R_gen = regcconcl AND Rientra.CFavv = NEW.CFavv)))
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'L\'avvocato non è associato al fascicolo';
    END IF;
END;
@@
DELIMITER ;

DELIMITER @@
CREATE TRIGGER CheckPFverb
    BEFORE INSERT
    ON PresenteVPF
    FOR EACH ROW
BEGIN
    /*DECLARE regcconcl INT;
    DECLARE vercita, vercitato CHAR(16);
    SELECT Rgen FROM Verbale_udienza WHERE Verbale_udienza.Id_Verbale = NEW.Idverb INTO regcconcl;
    IF (NOT EXISTS(SELECT CFpf FROM Cita WHERE Cita.CFpf = NEW.CFpf) OR
        NOT EXISTS(SELECT CFpf FROM CitaTO WHERE Citato.CFpf = NEW.CFpf))
    THEN
        SIGNAL sqlstate '45001' set message_text =
                'La persona fisica non è associata ad alcun fascicolo';
    ELSEIF ()
    END IF;*/
END;
@@
DELIMITER ;
#
# Riempimento tabelle
#
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Giudici.csv'
    INTO TABLE giudice
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Aule.csv'
    INTO TABLE Aula
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Matrgiud, Ubicazione);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Materie.csv'
    INTO TABLE Materia
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Descrizione);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Fascicoli.csv'
    INTO TABLE Fascicolo
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Anno, Cod_mat);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Verbali.csv'
    INTO TABLE Verbale_udienza
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Descrizione, Matricola_Giudice, Rgen, Data);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Pgiuridiche.csv'
    INTO TABLE Pgiuridica
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Ragione_sociale, PIva, Tipo_azienda, Rapplegale);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Pfisiche.csv'
    INTO TABLE Pfisica
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (CF, Cognome, Nome, Dnascita, Lnascita, Residenza, Ruolo);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Avvocati.csv'
    INTO TABLE Avvocato
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (CF, Cognome, Nome);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Niscruolo.csv'
    INTO TABLE niscrruolo
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Valore, Codmateria);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Depteste.csv'
    INTO TABLE depteste
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (CFTest, CFAvv, CFGiud);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Prove_documentali.csv'
    INTO TABLE prova_documentale
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Tipo, CFAvv);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Atticit.csv'
    INTO TABLE attocit
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Id_nota, Rgen);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Accessi.csv'
    INTO TABLE accede
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (R_gen, Codmatr);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Compconc.csv'
    INTO TABLE compconcl
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Rgen, Descrizione);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Memorie.csv'
    INTO TABLE Memoria186
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Tipo, Domande, Eccezioni, Conclusioni, RGen, Dpres);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Cita.csv'
    INTO TABLE Cita
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Idatto, CFpf, CFavv);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Citato.csv'
    INTO TABLE Citato
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Idatto, CFpf, CFavv);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CitatoPG.csv'
    INTO TABLE CitatoPG
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CitaPG.csv'
    INTO TABLE CitaPG
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ComponeAD.csv'
    INTO TABLE ComponeAD
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Idatto, Iddep);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ContieneMD.csv'
    INTO TABLE ContieneMD
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ComponeAP.csv'
    INTO TABLE ComponeAP
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Idatto, Idprova);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ContieneMP.csv'
    INTO TABLE ContieneMP
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Idmem, Idprova);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PresentaAM.csv'
    INTO TABLE PresentaAM
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Presenta.csv'
    INTO TABLE Presenta
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Include.csv'
    INTO TABLE Include
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n';

/*LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/RientraFPF.csv'
    INTO TABLE RientraFPF
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (CFPF,R_gen);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/RientraFPG.csv'
    INTO TABLE RientraFPG
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    (Piva,R_gen);*/


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Sentenze.csv'
    INTO TABLE Sentenza
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    (Rgen, Ammenda, Bgiur, Tipologia, Cmatr);

DELIMITER @@
CREATE PROCEDURE Ins_Verb(Regen INT,Descr VARCHAR(5000), matr CHAR(5))
BEGIN
    IF (NOT EXISTS(SELECT R_gen FROM accede WHERE (Accede.R_gen = Regen AND Accede.Codmatr=matr)))
    THEN
        BEGIN
            SIGNAL sqlstate '45001' set message_text =
                    'Questo fascicolo non è associato a lei';
        end;
    END IF;
   INSERT INTO Verbale_udienza (Data, Descrizione, Rgen,Matricola_Giudice) VALUES ('2023-01-11 09:45:30',Descr,Regen,matr);
end;
@@

DELIMITER ;

DELIMITER @@
CREATE PROCEDURE Ver_Verb(Verb INT,matr CHAR(5), OUT veritas BOOL)
BEGIN
    IF (NOT EXISTS(SELECT Matricola_Giudice FROM Verbale_udienza WHERE (Verbale_udienza.Matricola_Giudice=matr AND Verbale_udienza.Id_Verbale=Verb)))
    THEN
        BEGIN
            SET veritas=TRUE;
        end;
    ELSE
        SET veritas=FALSE;
    END IF;
end;
@@
DELIMITER ;

DELIMITER @@
CREATE PROCEDURE Mod_Verb(Verb INT, IN Descr VARCHAR(5000))
BEGIN
    UPDATE Verbale_udienza SET verbale_udienza.Descrizione=Descr WHERE Id_Verbale=Verb;
end;
@@
DELIMITER ;