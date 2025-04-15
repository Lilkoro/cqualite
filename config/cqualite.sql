-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 27 mars 2025 à 12:02
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `cqualite`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `dupliAudit` (IN `name` VARCHAR(20), IN `previousTable` VARCHAR(50))   BEGIN
    DECLARE itNum INT;        -- Variable pour l'itération
    DECLARE fullTableName VARCHAR(100); -- Variable pour le nom complet de la table
    DECLARE query1 TEXT;
    DECLARE query2 TEXT;
    DECLARE query3 TEXT;

    -- Vérifier ou créer une table pour stocker l'état de l'itération
    CREATE TABLE IF NOT EXISTS audit_table_counter (
        baseName VARCHAR(20) PRIMARY KEY,
        currentIt INT NOT NULL DEFAULT 0
    );

    -- Vérifier si l'entrée existe pour ce `name` dans la table `audit_table_counter`
    SELECT currentIt INTO itNum
    FROM audit_table_counter
    WHERE baseName = name
    FOR UPDATE;

    -- Si aucune entrée n'existe, en créer une et initialiser à 1
    IF itNum IS NULL THEN
        SET itNum = 1;
        INSERT INTO audit_table_counter (baseName, currentIt)
        VALUES (name, itNum);
    ELSE
        -- Incrémenter l'itération
        SET itNum = itNum + 1;
        UPDATE audit_table_counter
        SET currentIt = itNum
        WHERE baseName = name;
    END IF;

    -- Générer le nom complet de la table avec l'itération
    SET fullTableName = CONCAT(name, '_', itNum);

    -- Construire la requête pour créer une nouvelle table basée sur `previousTable`
    SET query1 = CONCAT('CREATE TABLE `', fullTableName, '` LIKE `', previousTable, '`;');

    -- Construire la requête pour insérer les données de `previousTable` dans la nouvelle table
    SET query2 = CONCAT('INSERT INTO `', fullTableName, '` SELECT * FROM `', previousTable, '`;');

    -- Construire la requête pour vider la colonne `note`
    SET query3 = CONCAT('UPDATE `', fullTableName, '` SET note = NULL;');

    -- Exécuter les requêtes dynamiques
    PREPARE stmt1 FROM query1;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    PREPARE stmt2 FROM query2;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    PREPARE stmt3 FROM query3;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `newAudit` (IN `name` VARCHAR(20))   BEGIN
    DECLARE query1 TEXT;
    DECLARE query2 TEXT;

    -- Construire dynamiquement les requêtes SQL
    SET query1 = CONCAT('CREATE TABLE `', name, '` LIKE questionaudit;');
    SET query2 = CONCAT('INSERT INTO `', name, '` SELECT * FROM questionaudit;');

    -- Préparer et exécuter les requêtes
    PREPARE stmt1 FROM query1;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    PREPARE stmt2 FROM query2;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `entreprise`
--

CREATE TABLE `entreprise` (
  `id` int(11) NOT NULL,
  `NOM1` varchar(54) DEFAULT NULL,
  `Nom` varchar(60) DEFAULT NULL,
  `Adresse` varchar(39) DEFAULT NULL,
  `Adresse2` varchar(24) DEFAULT NULL,
  `CPOST` varchar(5) DEFAULT NULL,
  `Ville` varchar(22) DEFAULT NULL,
  `Email Chef établissement` varchar(40) DEFAULT NULL,
  `Adjoint  Gestionnaire` varchar(29) DEFAULT NULL,
  `Email Adjoint Gestionnaire` varchar(41) DEFAULT NULL,
  `Tel` varchar(10) DEFAULT NULL,
  `Chef de cuisine` varchar(41) DEFAULT NULL,
  `Tél` varchar(22) DEFAULT NULL,
  `Email Chef de cuisine` varchar(48) DEFAULT NULL,
  `Coordonnateur Restauration` varchar(26) DEFAULT NULL,
  `NSiret` varchar(14) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Déchargement des données de la table `entreprise`
--

INSERT INTO `entreprise` (`id`, `NOM1`, `Nom`, `Adresse`, `Adresse2`, `CPOST`, `Ville`, `Email Chef établissement`, `Adjoint  Gestionnaire`, `Email Adjoint Gestionnaire`, `Tel`, `Chef de cuisine`, `Tél`, `Email Chef de cuisine`, `Coordonnateur Restauration`, `NSiret`) VALUES
(1, 'Test', 'Test', 'Adresse', 'Adresse2', 'CPOST', 'Ville', 'Email Chef établissement', 'Adjoint  Gestionnaire', 'Email Adjoint Gestionnaire', 'Tel', 'Chef de cuisine', 'Tél', 'Email Chef de cuisine', 'Coordonnateur Restauration', 'N° De SIRET'),
(2, 'Lycée Professionnel', 'MONTMAJOUR', 'chemin des Moines', '', '13200', 'ARLES', 'pr.lyc.montmajour@ac-aix-marseille.fr', 'Monsieur MAUGET Thierry', 'ges.lyc.montmajour@ac-aix-marseille.fr', '0490968050', '', '', '', 'Mr OUVIER Mathieu', '19130010200016'),
(3, 'Lycée d\'Enseignement Général et Technologique', 'L\'ESTAQUE', '310, rue Rabelais', '', '13016', 'MARSEILLE', 'pr.lyc.estaque@ac-aix-marseille.fr', 'Monsieur BENOUELHA Abdelhakim', 'ges.lyc.estaque@ac-aix-marseille.fr', '0495069070', 'TOUCHE Fabrice', '0762850543', 'ftouche@maregionsud.fr', 'LESAGE Franck', '19130058100011'),
(4, 'Lycée Professionnel', 'REMPART', '1, rue du Rempart', '', '13007', 'MARSEILLE', 'pr.lyc.rempart@ac-aix-marseille.fr', '', 'ges.lyc.rempart@ac-aix-marseille.fr', '0491143280', 'MACERA Frederic', '0660869757', 'fmacera@maregionsud.fr', 'LESAGE Franck', '19130049000015'),
(5, 'Lycée d\'Enseignement Général et Technologique', 'SAINT-CHARLES', '5, rue Guy Fabre', '', '13232', 'MARSEILLE', 'pr.lyc.stcharles@ac-aix-marseille.fr', 'Monsieur PAYRIERE Fernand', 'ges.lyc.stcharles@ac-aix-marseille.fr', '0491082050', 'MARI David', '0681135100', 'dmari@maregionsud.fr', 'LESAGE Franck', '19130039100015'),
(6, 'Lycée d\'Enseignement Général et Technologique', 'LES ISCLES', '116, boulevard Régis Ryckebush', '', '04100', 'MANOSQUE', 'pr.lyc.iscles@ac-aix-marseille.fr', 'Madame LEVEQUE Nathalie', 'ges.lyc.iscles@ac-aix-marseille.fr', '0492734110', 'M FERRUS Nicolas', '0763997779', 'nferrus@maregionsud.fr', 'HADOU Gaëtan', '19040492100016'),
(7, '', 'AUGUSTE RENOIR', 'avenue Marcel Pagnol', 'Boîte postale N°119', '06802', 'CAGNES SUR MER', 'proviseur.0060009c@ac-nice.fr', 'Madame PARISEL Elisabeth', 'gestionnaire.0060009c@ac-nice.fr', '0492024510', 'Mme RIBEIRO Sylvie', '0762836251', 'sribeiro@maregionsud.fr', '', '19060009800015'),
(8, 'Lycée Professionnel', 'SAINT-EXUPERY', '529, chemin de la Madrague Ville', '', '13015', 'MARSEILLE', 'pr.lyc.stexupery@ac-aix-marseille.fr', 'Monsieur BARBIER Cyril', 'ges.lyc.stexupery@ac-aix-marseille.fr', '0491096900', 'ARCOS David', '0617209732', 'darcos@maregionsud.fr', 'LESAGE Franck', '19130048200012'),
(9, 'Lycée Professionnel', 'VAUVENARGUES', '60, boulevard Carnot', '', '13100', 'AIX EN PROVENCE', 'pr.lyc.vauvenargues@ac-aix-marseille.fr', 'Monsieur GUEY Aurélien', 'ges.lyc.vauvenargues@ac-aix-marseille.fr', '0442174040', 'M ELISABETH Denis', '0762843607', 'delisabeth@maregionsud.fr', 'M HADOU Gaëtan', '19133206300012'),
(10, 'Lycée Polyvalent', 'JEAN COCTEAU', 'avenue Jean Cocteau ', '', '13140', 'MIRAMAS', 'pr.lyc.cocteau@ac-aix-marseille.fr', 'Madame RIBEYRE Elodie', 'ges.lyc.cocteau@ac-aix-marseille.fr', '0490500298', '', '', '', 'Mr OUVIER Mathieu', '19133195800014'),
(11, '', 'BRISTOL', 'CS 20114', '10, avenue Saint-Nicolas', '06414', 'CANNES', 'proviseur.0060013g@ac-nice.fr', 'Madame LAMA Laurence', 'gestionnaire.0060013g@ac-nice.fr', '0493067900', 'M. BOISET Florian', '0767749898', 'fboiset@maregionsud.fr', '', '19060013000016'),
(12, '', 'RENE GOSCINNY', '500 route DE CROVES', '', '06340', 'DRAP', 'proviseur.0062089n@ac-nice.fr', 'Monsieur FLEMING Franck', 'gestionnaire.0062089n@ac-nice.fr', '0492143450', 'M. CHOUTEAU Gaëtan', '0676259753', 'gchouteau@maregionsud.fr', '', '20003226600013'),
(13, '', 'ARTHUR RIMBAUD', 'Quartier des Salles', '', '13808', 'ISTRES', 'pr.lyc.rimbaud@ac-aix-marseille.fr', 'Monsieur BIGOT Michael', 'ges.lyc.rimbaud@ac-aix-marseille.fr', '0442411096', 'VANDAL Patrice', '0625575580', 'pvandal@maregionsud.fr', 'LESAGE Franck', '19132495300014'),
(14, '', 'JULES FERRY', '82, boulevard de la République', 'BP 265', '06402', 'CANNES', 'proviseur.0060014h@ac-nice.fr', 'Madame GIRON Audrey', 'gestionnaire.0060014h@ac-nice.fr', '0493065200', 'M. MORGHILEM-MENU Ludovic', '0603152195', 'lmorghilemmenu@maregionsud.fr', '', '19060014800018'),
(15, 'Lycée Polyvalent', 'THIERS', '5, place du Lycée Thiers', '', '13232', 'MARSEILLE', 'pr.lyc.thiers@ac-aix-marseille.fr', 'Monsieur AIMONETTI Gael', 'ges.lyc.thiers@ac-aix-marseille.fr', '0491189218', 'MOKHTARI Nesrine', '0635184220', 'nemokhtari@maregionsud.fr', 'LESAGE Franck', '19130040900015'),
(16, 'Lycée Polyvalent', 'LE CHATELIER', '108, avenue Roger Salengro', '', '13003', 'MARSEILLE', 'pr.lyc.chatelier@ac-aix-marseille.fr', '', 'ges.lyc.chatelier@ac-aix-marseille.fr', '0495045500', 'SQUILLACE Bruno', '0659701773', 'bsquillace@maregionsud.fr', 'LESAGE Franck', '19130055700011'),
(17, '', 'VAUBAN', '17, boulevard Pierre Sola', '', '06300', 'NICE', 'proviseur.0060038j@ac-nice.fr', 'Madame FAUBOURG Isabelle', 'gestionnaire.0060038j@ac-nice.fr', '0493550011', 'M. TORNATORE Didier', '0601443408', 'dtornatore@maregionsud.fr', '', '19060038700012'),
(18, '', 'DE LA MONTAGNE', 'La Bolline', 'Quartier du Clôt', '06420', 'VALDEBLORE', 'proviseur.0061987c@ac-nice.fr', 'Madame JUMAIN-HARCOUR Claire', 'gestionnaire.0061987c@ac-nice.fr', '0493053300', 'Mme RUZS Fabienne', '0695635944', 'fruzs@maregionsud.fr', '', '19061696100016'),
(19, '', 'JACQUES DOLLE', '120, rue de Saint-Claude', '', '06600', 'ANTIBES', 'proviseur.0060002v@ac-nice.fr', '', 'gestionnaire.0060002v@ac-nice.fr', '0492917917', 'M. PANAIS Arnaud ', '0762835928', 'apanais@maregionsud.fr', '', '19060002300021'),
(20, '', 'FRANCIS DE CROISSET', '34, chemin de la Cavalerie', 'Quartier Saint-Claude', '06130', 'GRASSE', 'proviseur.0060023t@ac-nice.fr', 'Madame FRANCHINI Marie', 'gestionnaire.0060023t@ac-nice.fr', '0492424860', 'M. THUREL Philippe ', '0762850616', 'pthurel@mareionsud.fr', '', '19060023900023'),
(21, 'Lycée Professionnel', 'REGIONAL LA CALADE - JANE VIALLE', '430, chemin de la Madrague Ville', '', '13015', 'MARSEILLE', 'pr.lyc.calade@ac-aix-marseille.fr', 'Monsieur ROYNETTE Frédéric', 'ges.lyc.calade@ac-aix-marseille.fr', '0491658650', 'BLACHERE Laurent', '0622454582', 'lblachere@maregionsud.fr', 'LESAGE Franck', '19131606600015'),
(22, 'Lycée Professionnel', 'PIERRE-GILLES DE GENNES', 'Quartier Saint-Christophe', '', '04000', 'DIGNE LES BAINS', 'pr.lyc.provence@ac-aix-marseille.fr', 'Madame LEDOUX Laurence', 'ges.lyc.provence@ac-aix-marseille.fr', '0492367190', 'M VIDAU Daniel', '0763997782', 'dviadau@maregionsud.fr', 'HADOU Gaëtan', '19040490500019'),
(23, 'Lycée d\'Enseignement Général et Technologique', 'LA FLORIDE', '54, boulevard Gay-Lussac', 'Z.I.N. 903', '13014', 'MARSEILLE', 'pr.lyc.floride@ac-aix-marseille.fr', 'Madame TRAMONT', 'ges.lyc.floride@ac-aix-marseille.fr', '0495053535', 'DEMANGEL Christophe', '0626710398', 'cdemangel@maregionsud.fr', 'LESAGE Franck', '19130056500014'),
(24, 'Lycée Professionnel', 'REGIONAL HOTELIER JEAN-PAUL PASSEDAT', '114 avenue Zenatti', 'BP 18', '13266', 'MARSEILLE', 'pr.lyc.hotelier@ac-aix-marseille.fr', 'Monsieur DUGELAY Emmanuel', 'ges.lyc.hotelier@ac-aix-marseille.fr', '0491734781', 'NATALI Pierre', '0762836404', 'pnatali@maregionsud.fr', 'LESAGE Franck', '19132974700015'),
(25, '', 'AMPERE', '56, boulevard Romain Rolland', '', '13010', 'MARSEILLE', 'pr.lyc.ampere@ac-aix-marseille.fr', 'Madame MELLANO Anouk', 'ges.lyc.ampere@ac-aix-marseille.fr', '0491298400', 'ESBRAT Philippe', '0771787640', 'pesbrat@maregionsud.fr', 'LESAGE Franck', '19133205500026'),
(26, '', 'LEON CHIRIS', '51, chemin des Capucins', '', '06130', 'GRASSE', 'proviseur.0060022s@ac-nice.fr', 'Monsieur MOULINET Christophe', 'gestionnaire.0060022s@ac-nice.fr', '0493709530', 'Mme LECLERC Murielle (seconde de cuisine)', '0681930948', 'mleclerc@maregionsud.fr', '', '19060022100013'),
(27, '', 'ALEXIS DE TOCQUEVILLE', '22, chemin de l\'Orme', 'BP 72111', '06130', 'GRASSE', 'proviseur.0061760f@ac-nice.fr', 'Madame TOURNAIRE Danièle', 'gestionnaire.0061760f@ac-nice.fr', '0493098092', 'M. ADJALI Romain (second de cuisine)', '0649701123', 'radjali@maregionsud.fr', '', '19060005600013'),
(28, 'Lycée Professionnel Agricole', 'RENE CAILLIE', '173, boulevard de Saint-Loup', '', '13011', 'MARSEILLE', 'pr.lyc.caillie@ac-aix-marseille.fr', '', 'ges.lyc.caillie@ac-aix-marseille.fr', '0491181006', 'GUIBERT Jean Gabriel', '0670247799', 'jgguibert@maregionsud.fr', 'LESAGE Franck', '19130057300026'),
(29, 'Lycée Polyvalent', 'LA VISTE', 'traverse Bonnet', '', '13015', 'MARSEILLE', 'pr.lyc.viste@ac-aix-marseille.fr', '', 'ges.lyc.viste@ac-aix-marseille.fr', '0491659040', 'ITINERANT', '', '', 'LESAGE Franck', '19130065600011'),
(30, '', 'SIMONE VEIL', '1265 route de Biot', 'Quartier de la Bourelle', '06560', 'VALBONNE', 'proviseur.0062015h@ac-nice.fr', 'Madame GEOFFROY Céline', 'gestionnaire.0062015h@ac-nice.fr', '0497973300', 'M. PICHON Vincent', '0618632033', 'vpichon@maregionsud.fr', '', '20000181600012'),
(31, 'Lycée d\'Enseignement Général et Technologique', 'MARIE-MADELEINE FOURCADE\n\n2 sites de production sur GARDANNE', 'avenue du Groupe Manouchian', '', '13120', 'GARDANNE', 'pr.lyc.fourcade@ac-aix-marseille.fr', 'Madame CAMPELLO Vanessa', 'ges.lyc.fourcade@ac-aix-marseille.fr', '0442659070', 'M ZAMORA Laurent\nM PELLEGRIN Anthony', '0762842327\n\n0762834712', 'lzamora@maregionsud.fr\napellegrin@maregionsud.fr', 'M HADOU Gaëtan', '19130559800010'),
(32, '', 'CAMPUS NATURE PROVENCE', 'chemin du moulin du fort', '', '13548', 'GARDANNE', 'hassan.samr@educagri.fr', 'Monsieur FRANCOU Thomas', 'thomas.francou@educagri.fr', '0442654320', 'M PASOTTO Walter', '0762835831', 'wpasotto@maregionsud.fr', 'M HADOU Gaëtan', '19131656100015'),
(33, '', 'MAGNAN', '34, rue Auguste Renoir', '', '06000', 'NICE', 'proviseur.0060043p@ac-nice.fr', 'Madame DA SILVA Vanessa', 'gestionnaire.0060043p@ac-nice.fr', '0497072222', 'Mme BUSNEL Nathalie', '0762843978', 'nbusnel@maregionsud.fr', '', '19060043700023'),
(34, 'Lycée d\'Enseignement Général et Technologique', 'MONTGRAND', '13, rue Montgrand', '', '13006', 'MARSEILLE', 'pr.lyc.montgrand@ac-aix-marseille.fr', 'Madame ZURYLO Barbara', 'ges.lyc.montgrand@ac-aix-marseille.fr', '0496112530', 'SUMIAN Agnes', '0663997387', 'asumian@maregionsud.fr', 'LESAGE Franck', '19130042500011'),
(35, '', 'LES EUCALYPTUS', '7, avenue des eucalyptus', 'BP 83306 ', '06206', 'NICE', 'proviseur.0060075z@ac-nice.fr', 'Monsieur GRATPANCHE Hervé', 'gestionnaire.0060075z@ac-nice.fr', '0492293030', 'M.OUSTRIC Mickaël', '0762835772', 'moustric@maregionsud.fr', '', '19060075900012'),
(36, 'Lycée Professionnel', 'LEAU', '63, boulevard Leau', '', '13008', 'MARSEILLE', 'pr.lyc.leau@ac-aix-marseille.fr', 'Monsieur ABOUDOU Sabourata', 'ges.lyc.leau@ac-aix-marseille.fr', '0491163710', 'MOLISANO Bruno', '0684850581', 'bmolisani@maregionsud.fr', 'LESAGE Franck', '19130063100014'),
(37, '', 'GUILLAUME APOLLINAIRE', '29, boulevard Jean-Baptiste Vérany', '', '06300', 'NICE', 'proviseur.0061763j@ac-nice.fr', 'Monsieur TRAPANI Jérome', 'gestionnaire.0061763j@ac-nice.fr', '0493928535', 'M. SCRIVA René', '0762851061', 'rscriva@maregionsud.fr', '', '19060004900018'),
(38, 'Lycée Professionnel', 'GERMAINE POINSO-CHAPUIS', '49, traverse Parangon', '', '13272', 'MARSEILLE', 'pr.lyc.poinsochapuis@ac-aix-marseille.fr', 'Mademoiselle LEZIAN Mareva', 'ges.lyc.poinsochapuis@ac-aix-marseille.fr', '0491167700', 'ABED Fadela', '0667970451', 'fmedalel@maregionsud.fr', 'LESAGE Franck', '19130054000025'),
(39, '', 'AUGUSTE & LOUIS LUMIERE', 'avenue Jules Ferry', '', '13600', 'LA CIOTAT', 'pr.lyc.lumiere@ac-aix-marseille.fr', 'Madame CAMBRA Laëtitia', 'ges.lyc.lumiere@ac-aix-marseille.fr', '0442083838', '', '', '', '', '19131747800011'),
(40, '', 'MASSENA', '2, avenue Félix Faure', '', '06047', 'NICE', 'proviseur.0060030a@ac-nice.fr', 'Monsieur DUFRESNE Nicolas', 'gestionnaire.0060030a@ac-nice.fr', '0493627700', 'M. FOLGOA Jean-Claude', '0762827136', 'jcfolgoa@maregionsud.fr', '', '19060030400017'),
(41, 'Lycée Professionnel', 'PERIER', '270 rue Paradis', '', '13295', 'MARSEILLE', 'pr.lyc.perier@ac-aix-marseille.fr', 'Monsieur SARTORE Jean-Pierre', 'ges.lyc.perier@ac-aix-marseille.fr', '0491133900', 'MORIN Francois', '0762836494', 'fmorin@maregionsud.fr', 'LESAGE Franck', '19130036700015'),
(42, 'Lycée d\'Enseignement Général et Technologique', 'DENIS DIDEROT', '23, boulevard Lavéran', '', '13013', 'MARSEILLE', 'pr.lyc.diderot@ac-aix-marseille.fr', 'Monsieur MOAFFEK Fatima', 'ges.lyc.diderot@ac-aix-marseille.fr', '0491100700', 'GRAND Sebastien', '0681935309', 'sgrand@maregionsud.fr', 'LESAGE Franck', '19130050800030'),
(43, 'Lycée d\'Enseignement Général et Technologique', 'LOUIS MARTIN BRET', 'Allée du Parc', 'BP90111', '04101', 'MANOSQUE', 'pr.lyc.bret@ac-aix-marseille.fr', 'Madame FLEURIOT Cécile', 'ges.lyc.bret@ac-aix-marseille.fr', '0492707840', 'M LABROUSSE Eric', 'En cours', 'elabrousse@maregionsud.fr', 'HADOU Gaëtan', '19040011900011'),
(44, 'Lycée Professionnel', 'PAUL CEZANNE', 'avenue Jean et Marcel Fontenaille', '', '13100', 'AIX EN PROVENCE', 'pr.lyc.cezanne@ac-aix-marseille.fr', 'Monsieur MASSOT Daniel', 'ges.lyc.cezanne@ac-aix-marseille.fr', '0442171400', 'M BLAYA Laurent', '0665462355', 'lblaya@maregionsud.fr', 'M HADOU Gaëtan', '19130002900011'),
(45, 'Lycée Professionnel', 'DES CALANQUES', '89 traverse Parangon', '', '13008', 'MARSEILLE', 'gilles.floureau@educagri.fr', 'Madame MILOU Agathe', 'agathe.milou@educagri.fr', '0491727070', 'PONS Gilles', '0626817320', 'gpons@maregionsud.fr', 'LESAGE Franck', '19131656100098'),
(46, 'Lycée Professionnel', 'FREDERIC JOLIOT-CURIE', 'avenue des Goums', 'CS80920', '13677', 'AUBAGNE', 'pr.lyc.joliotcurie@ac-aix-marseille.fr', 'Monsieur BARONTI Sandrine', 'ges.lyc.joliotcurie@ac-aix-marseille.fr', '0442185151', '', '', '', '', '19131549800011'),
(47, '', 'BLAISE PASCAL', '49 traverse Capron', '', '13012', 'MARSEILLE', 'pr.lyc.pascal@ac-aix-marseille.fr', 'Madame SPANO Corinne', 'ges.lyc.pascal@ac-aix-marseille.fr', '0491180340', 'ITINERANT', '', '', 'LESAGE Franck', '19130059900013'),
(48, '', 'D\'ESTIENNE D\'ORVES', '13, avenue d\'Estienne D\'Orves', '', '06050', 'NICE', 'proviseur.0060033d@ac-nice.fr', 'Monsieur HOYER Régis', 'gestionnaire.0060033d@ac-nice.fr', '0493971200', 'M. SAILLY Bruno', '0762838696', 'bsailly@maregionsud.fr', '', '19060033800015'),
(49, 'Lycée d\'Enseignement Général et Technologique', 'PAUL ARENE', 'Quartier de Beaulieu', 'BP 98', '04203', 'SISTERON', 'pr.lyc.arene@ac-aix-marseille.fr', 'Madame GOUDET Fabienne', 'ges.lyc.arene@ac-aix-marseille.fr', '0492610299', 'M GARCIA Christophe-Luc', '0762833488', 'clgarcia@maregionsud.fr', 'HADOU Gaëtan', '19040023400018'),
(50, '', 'AMIRAL DE GRASSE', '20, avenue Sainte Lorette', '', '06130', 'GRASSE', 'proviseur.0060020p@ac-nice.fr', 'Monsieur', 'gestionnaire.0060020p@ac-nice.fr', '0493406380', 'Mme COCHET Elisabeth (seconde de cuisine)', '0762843723', 'ecochet@maregionsud.fr', '', '19060020500016'),
(51, '', 'AUGUSTE ESCOFFIER', 'chemin du Brecq', 'BP 511', '06801', 'CAGNES SUR MER', 'proviseur.0061635v@ac-nice.fr', 'Madame CROS Bénédicte', 'gestionnaire.0061635v@ac-nice.fr', '0492134880', 'M.LOCHON Olivier ', '0762828457', 'lolochon@maregionsud.fr', '', '19060006400017'),
(52, '', 'CAMPUS VERT D\'AZUR', '1285 avenue 1285, Jules Grec', 'BP89', '06602', 'ANTIBES', 'jean-luc.plo@educagri.fr', 'Monsieur SUNER Frédéric', 'frederic.suner@educagri.fr', '0492914444', 'M. BOYER Bernard', '0646723382', 'bboyer@maregionsud.fr', '', '19060793700017'),
(53, '', 'CARNOT', '90, boulevard Carnot', 'BP 296', '06408', 'CANNES', 'proviseur.0060011e@ac-nice.fr', 'Madame RABOT Murielle', 'gestionnaire.0060011e@ac-nice.fr', '0492993888', 'M. FRANCO Bruno', '0649287305', 'bfranco@maregionsud.fr', '', '19060011400010'),
(54, '', 'PIERRE & MARIE CURIE', '353, avenue du Doyen Jean Lépine', '', '06500', 'MENTON', 'proviseur.0060026w@ac-nice.fr', 'Madame MIRGAINE Véronique', 'gestionnaire.0060026w@ac-nice.fr', '0492105440', 'M. SANCHEZ Joel', '0762838331', 'jsanchez@maregionsud.fr', '', '19060026200017'),
(55, '', 'ALPHONSE DAUDET', 'Boulevard Jules Ferry', 'BP 12', '13158', 'TARASCON', 'pr.lyc.daudet@ac-aix-marseille.fr', 'Madame REVEL Stéphanie', 'ges.lyc.daudet@ac-aix-marseille.fr', '0490911823', '', '', '', 'Mr OUVIER Mathieu', '19130164700019'),
(56, '', 'ANTONIN ARTAUD', '25, chemin Notre-Dame de la Consolation', '', '13388', 'MARSEILLE', 'pr.lyc.artaud@ac-aix-marseille.fr', 'Monsieur LABSI Rachid', 'ges.lyc.artaud@ac-aix-marseille.fr', '0491122250', 'BEN HAMED DAO Miloud', '0782069700', 'mben_ahmed_daho@maregionsud.fr', 'LESAGE Franck', '19132733700017'),
(57, '', 'CAMILLE JULLIAN', '50, boulevard de la Barasse', '', '13396', 'MARSEILLE', 'pr.lyc.jullian@ac-aix-marseille.fr', 'Madame DETONGNON Marion', 'ges.lyc.jullian@ac-aix-marseille.fr', '0491888300', 'LORENZI Eric', '0762828327', 'elorenzi@maregionsud.fr', 'LESAGE Franck', '19130068000011'),
(58, 'Lycée d\'Enseignement Général et Technologique', 'CHARLES MONGRAND', '10 boulevard Cristofol', '', '13110', 'PORT DE BOUC', 'pr.lyc.mongrand@ac-aix-marseille.fr', 'Madame DUREL Peggy', 'ges.lyc.mongrand@ac-aix-marseille.fr', '0442350470', 'MODOLO Frederic', '0648105865', 'fmodolo@maregionsud.fr', 'LESAGE Franck', '19130151400029'),
(59, 'Lycée Professionnel', 'CHARLES PRIVAT', '10, rue Lucien GUINTOLI', 'BP 71', '13632', 'ARLES', 'pr.lyc.privat@ac-aix-marseille.fr', 'Madame COURTAT Maryse', 'ges.lyc.privat@ac-aix-marseille.fr', '0490496044', '', '', '', 'Mr OUVIER Mathieu', '19130171200011'),
(60, 'Lycée d\'Enseignement Général et Technologique Agricole', 'COLBERT', '13, rue du Capitaine Dessemond', '', '13284', 'MARSEILLE', 'pr.lyc.colbert@ac-aix-marseille.fr', 'Madame FOURNO Laurence', 'ges.lyc.colbert@ac-aix-marseille.fr', '0491310452', 'GERMAIN Lionel', '0609234255', 'lgermain@maregionsud.fr', 'LESAGE Franck', '19130071400018'),
(61, 'Lycée d\'Enseignement Général et Technologique Agricole', 'DE L\'EMPERI', 'Montée du Puech', 'BP 134', '13657', 'SALON DE PROVENCE', 'pr.lyc.emperi@ac-aix-marseille.fr', 'Madame PINAU-SUARD Muriel', 'ges.lyc.emperi@ac-aix-marseille.fr', '0490447900', '', '', '', 'Mr OUVIER Mathieu', '19130160500017'),
(62, 'Lycée Professionnel Agricole', 'LATECOERE', 'Avenue des Bolles', '', '13800', 'ISTRES', 'pr.lyc.latecoere@ac-aix-marseille.fr', 'Madame BOULAY Guylaine', 'ges.lyc.latecoere@ac-aix-marseille.fr', '0442411950', 'DO Julien', '0623403598', 'jdo@maregionsud.fr', 'LESAGE Franck', '19132276700010'),
(63, 'Lycée d\'Enseignement Général et Technologique', 'LES ALPILLES', '91, avenue Edouard Herriot', '', '13210', 'SAINT REMY DE PROVENCE', 'jean-louis.brifflot@educagri.fr', 'Madame TAVEAU Antoinette', 'antoinette.taveau@educagri.fr', '0490920320', '', '', '', 'Mr OUVIER Mathieu', '19131715500015'),
(64, 'Lycée Professionnel', 'LES FERRAGES', 'quartier Les Ferrages', 'BP 52', '13250', 'SAINT CHAMAS', 'pr.lyc.ferrages@ac-aix-marseille.fr', 'Madame FILA Nadiège', 'ges.lyc.ferrages@ac-aix-marseille.fr', '0490507036', '', '', '', 'Mr OUVIER Mathieu', '19130157100011'),
(65, 'Lycée Professionnel', 'LOUIS BLERIOT', '8, boulevard de la Libération', 'BP 10', '13700', 'MARIGNANE', 'pr.lp.bleriot@ac-aix-marseille.fr', 'Monsieur BOUROUBI Yacine', 'ges.lp.bleriot@ac-aix-marseille.fr', '0442093050', 'SALORT Stephanie', '0622687050', 'ssalort@maregionsud.fr', 'LESAGE Franck', '19130033400015');

-- --------------------------------------------------------

--
-- Structure de la table `modelaudit`
--

CREATE TABLE `modelaudit` (
  `id` int(11) NOT NULL,
  `nomModelAudit` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `modelaudit`
--

INSERT INTO `modelaudit` (`id`, `nomModelAudit`) VALUES
(1, 'Audit');

-- --------------------------------------------------------

--
-- Structure de la table `questionaudit`
--

CREATE TABLE `questionaudit` (
  `id` int(11) NOT NULL,
  `indicateur` varchar(101) DEFAULT NULL,
  `question` varchar(338) DEFAULT NULL,
  `note` varchar(11) DEFAULT NULL,
  `obsEcart` varchar(255) DEFAULT NULL,
  `suggPlanAction` varchar(255) DEFAULT NULL,
  `picPath` varchar(255) DEFAULT NULL,
  `idTheme` int(10) NOT NULL,
  `etat` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Déchargement des données de la table `questionaudit`
--

INSERT INTO `questionaudit` (`id`, `indicateur`, `question`, `note`, `obsEcart`, `suggPlanAction`, `picPath`, `idTheme`, `etat`) VALUES
(1, 'TRAC', 'Fournisseurs de denrées d\'origine(s) animale(s) pourvus d\'un agrément sanitaire (ou dérogation)', NULL, NULL, NULL, NULL, 1, NULL),
(2, 'BPH', 'Limitation du temps d\'attente des denrées réfrigérées ou surgelées à température ambiante.', NULL, NULL, NULL, NULL, 1, NULL),
(3, 'DOC', 'Affichage du document \"Température à réception\"', NULL, NULL, NULL, NULL, 1, NULL),
(4, 'MAT', 'Présence d\'un thermomètre à sonde et d\'un thermomètre laser en état de marche', NULL, NULL, NULL, NULL, 1, NULL),
(5, 'DOC', 'Respect de la procédure de contrôle réception avec enregistrement systématique  T°C, Date, Etat des emballages/produits', NULL, NULL, NULL, NULL, 1, NULL),
(6, 'DOC', 'Présence de fiche d\'anomalie à réception', NULL, NULL, NULL, NULL, 1, NULL),
(7, 'BPH', 'Port d\'une blouse adaptée pour la réception des marchandises', NULL, NULL, NULL, NULL, 1, NULL),
(8, 'NONE', 'Existe-t-il un protocole de chargement/déchargement pour chaque fournisseur ? Préciser le nombre et les noms des fournisseurs :', NULL, NULL, NULL, NULL, 1, NULL),
(9, 'BPH', 'Respect de la sectorisation par catégorie des produits stockés', NULL, NULL, NULL, NULL, 2, NULL),
(10, 'LOC', 'Enceintes frigorifiques non surchargées', NULL, NULL, NULL, NULL, 2, NULL),
(11, 'BPH', 'Rangement évitant les contaminations croisées  Denrées protégées, pas de produits au sol, pas de produits autres qu\'alimentaires, …', NULL, NULL, NULL, NULL, 2, NULL),
(12, 'BPH', 'Absence de défaut de fraicheur des produits Fruits et légumes moisis...', NULL, NULL, NULL, NULL, 2, NULL),
(13, 'BPH', 'Absence de conditionnements présentant des défauts Conserves cabossées, sous vide fuité...', NULL, NULL, NULL, NULL, 2, NULL),
(14, 'BPH', 'Absence de produits sans identification', NULL, NULL, NULL, NULL, 2, NULL),
(15, 'BPH', 'Absence de produits ayant une DLC dépassée en stock.', NULL, NULL, NULL, NULL, 2, NULL),
(16, 'BPH', 'Rotation des produits selon les dates', NULL, NULL, NULL, NULL, 2, NULL),
(17, 'BPH', 'Absence de produits ayant une DDM dépassée en stock.', NULL, NULL, NULL, NULL, 2, NULL),
(18, 'DOC', 'Enregitrement des T°C des enceintes réfrigérées conforme', NULL, NULL, NULL, NULL, 2, NULL),
(19, 'BPH', 'Respect de la procédure de contrôle des T°C des enceintes réfrigérées', NULL, NULL, NULL, NULL, 2, NULL),
(20, 'TEMP', 'Conformité des T° des enceintes frigorifiques positives - BOF : +3°C - Fruits et légumes : +8°C - Viande et charcuterie : +3°C - Frigo jour plats préparé : +3°C', NULL, NULL, NULL, NULL, 2, NULL),
(21, 'TEMP', 'Conformité des T° des enceintes frigorifiques négatives (-18°C)', NULL, NULL, NULL, NULL, 2, NULL),
(22, 'BPH', 'Absence de denrées congelées sur place  Sauf pain, dans contenant daté, DVS<15j', NULL, NULL, NULL, NULL, 2, NULL),
(23, 'MAT', 'Les différentes enceintes de froid sont équipées de thermomètres à lecture directe, d\'un thermomètre mobile ou d\'un système de surveillance (Alarme). ', NULL, NULL, NULL, NULL, 2, NULL),
(24, 'BPH', 'Respect des protocoles de déconditionnement (déboîtage, dessouvidage)', NULL, NULL, NULL, NULL, 3, NULL),
(25, 'DOC', 'Affichage du protocole de décontamination des végétaux ', NULL, NULL, NULL, NULL, 3, NULL),
(26, 'BPH', 'Respect du protocole de décontamination des végétaux consommés crus 30ml de solution chlorée à 2,6% dans 50L d\'eau', NULL, NULL, NULL, NULL, 3, NULL),
(27, 'BPH', 'Dispositions évitant les contaminations croisées', NULL, NULL, NULL, NULL, 3, NULL),
(28, 'TEMP', 'Maîtrise des temps d\'attente hors froid', NULL, NULL, NULL, NULL, 3, NULL),
(29, 'BPH', 'Progression logique des denrées dans la zone (entrée / traitement / sortie)', NULL, NULL, NULL, NULL, 3, NULL),
(30, 'TRAC', 'Conservation des éléments de traçabilité de tout produit déconditionné Numérisation de toutes les étiquettes', NULL, NULL, NULL, NULL, 3, NULL),
(31, 'BPH', 'Absence de décongélation à température ambiante', NULL, NULL, NULL, NULL, 3, NULL),
(32, 'BPH', 'Dispositions évitant les contaminations croisées', NULL, NULL, NULL, NULL, 4, NULL),
(33, 'BPH', 'Respect des bonnes pratiques d\'utilisation des œufs coquilles', NULL, NULL, NULL, NULL, 4, NULL),
(34, 'TEMP', 'Exposition limitée des produits semi-finis et finis en dehors des enceintes réfrigérées        30 min maximum', NULL, NULL, NULL, NULL, 4, NULL),
(35, 'TRAC', 'Les produits finis, en cours d\'utilisation et semi-finis sont protégés, identifiés et datés', NULL, NULL, NULL, NULL, 4, NULL),
(36, 'DOC', 'Disponibilité/affichage des durées de vie des produits déconditionnés', NULL, NULL, NULL, NULL, 4, NULL),
(37, 'BPH', 'Respect des durées de vie des produits décongelés  3 jours y compris le jour de mise en décongélation', NULL, NULL, NULL, NULL, 4, NULL),
(38, 'BPH', 'Respect des durées de vie des matières premières déconditionnées Voir PMS', NULL, NULL, NULL, NULL, 4, NULL),
(39, 'BPH', 'Respect des durées de vie des produits intermédiaires et produits finis', NULL, NULL, NULL, NULL, 4, NULL),
(40, 'BPH', 'Absence d\'emballage dans la zone de production froide (cartons, boites de conserve…)', NULL, NULL, NULL, NULL, 4, NULL),
(41, 'BPH', 'Conditionnements utilisés conformes (alimentarité, vétustée…)', NULL, NULL, NULL, NULL, 4, NULL),
(42, 'BPH', 'Dispositions évitant les contaminations croisées', NULL, NULL, NULL, NULL, 5, NULL),
(43, 'TRAC', 'Les produits finis, en cours d\'utilisation et semi-finis sont protégés, identifiés et datés. ', NULL, NULL, NULL, NULL, 5, NULL),
(44, 'BPH', 'Respect de la procédure de refroidissement ', NULL, NULL, NULL, NULL, 5, NULL),
(45, 'DOC', 'Enregitrement des refroidissements conforme', NULL, NULL, NULL, NULL, 5, NULL),
(46, 'BPH', 'Respect des durées de vie des produits intermédiaires et produits finis', NULL, NULL, NULL, NULL, 5, NULL),
(47, 'BPH', 'Respect de la procédure de réchauffage (matériel, méthode, enregistrement)', NULL, NULL, NULL, NULL, 5, NULL),
(48, 'DOC', 'Enregitrement des réchauffages conforme', NULL, NULL, NULL, NULL, 5, NULL),
(49, 'TEMP', 'Respect du maintien à température après cuisson (+63°C minimum)', NULL, NULL, NULL, NULL, 5, NULL),
(50, 'BPH', 'Sonde des cellules de refroidissement désinféctées avant utilisation', NULL, NULL, NULL, NULL, 5, NULL),
(51, 'BPH', 'Absence d\'emballage dans la zone de production chaude (cartons, boites de conserve…)', NULL, NULL, NULL, NULL, 5, NULL),
(52, 'BPH', 'Conditionnements utilisés conformes (alimentarité, vétustée…)', NULL, NULL, NULL, NULL, 5, NULL),
(53, 'BPH', 'Respect de la procédure de prélèvement des plats témoins Min 100g, en cours ou en fin de service', NULL, NULL, NULL, NULL, 6, NULL),
(54, 'BPH', 'Protection satisfaisante des produits présentés au service', NULL, NULL, NULL, NULL, 6, NULL),
(55, 'BPH', 'Respect de la procédure de gestion des plats témoins  Conservation 7j min., à +3°C, identifiés', NULL, NULL, NULL, NULL, 6, NULL),
(56, 'TRAC', 'Informations sur la provenance des viandes à disposition et à jour.', NULL, NULL, NULL, NULL, 6, NULL),
(57, 'TRAC', 'Informations sur les allergènes à disposition et à jour.', NULL, NULL, NULL, NULL, 6, NULL),
(58, 'BPH', 'Présence de la procédure et du matériel de contrôle des huiles de friture', NULL, NULL, NULL, NULL, 6, NULL),
(59, 'BPH', 'Respect de la procédure de contrôle des huiles de friture. Contrôle visuel ou à l\'aide de test après chaque utilisation', NULL, NULL, NULL, NULL, 6, NULL),
(60, 'DOC', 'Enregistrement des contrôles des huiles de friture conforme', NULL, NULL, NULL, NULL, 6, NULL),
(61, 'BPH', 'Utilisation des friteuses conforme T°C max 180°C, bains d\'huile différents pour frites/autre produits, filtration ', NULL, NULL, NULL, NULL, 6, NULL),
(62, 'BPH', 'Qualité de l\'huile conforme Composés polaires <25% (test par auditeur)', NULL, NULL, NULL, NULL, 6, NULL),
(63, 'TEMP', 'Conformité des T°C des préparations froides au moment du service  +10°C maximum', NULL, NULL, NULL, NULL, 6, NULL),
(64, 'TEMP', 'Conformité des T°C des préparations chaudes au moment du service  +63°C minimum', NULL, NULL, NULL, NULL, 6, NULL),
(65, 'TEMP', 'Conformité des températures des meubles de maintien  +90°C pour les bain-maries, +3°C pour les vitrines réfrigérées', NULL, NULL, NULL, NULL, 6, NULL),
(66, 'BPH', 'Respect de la procédure de contrôle des T°C en distribution (chaude et froide) En début et en cours de service ', NULL, NULL, NULL, NULL, 6, NULL),
(67, 'DOC', 'Enregistrement des contrôles de T°C en distribution conforme', NULL, NULL, NULL, NULL, 6, NULL),
(68, 'BPH', 'Respect du protocole de cuisson des steaks hachés  Cuisson minute, min. +65°C à coeur, en étuve 15-20min max', NULL, NULL, NULL, NULL, 6, NULL),
(69, 'BPH', 'Gestion des excedents   Jeter : tout reliquat de produit chaud et froids présentés à la vente Peuvent être resservis le lendemain : entrées et desserts conservés au frigo, plats chauds conservés en armoire et refroidis, laitages préemballés en vitrine', NULL, NULL, NULL, NULL, 6, NULL),
(70, 'BPH', 'Respect des durées de vie des produits finis J+3 max. sauf préparation hachée, tranchée et plats refroidis après service (J+1)', NULL, NULL, NULL, NULL, 6, NULL),
(71, 'TEMP', 'Les températures des équipements de transport sont conformes', NULL, NULL, NULL, NULL, 7, NULL),
(72, 'DOC', 'Les températures des équipements de transport sont contrôlées et enregistrées.', NULL, NULL, NULL, NULL, 7, NULL),
(73, 'BPH', 'Les denrées alimentaires sont transportées dans des équipements réservés et protégées de manière adéquate pendant le transport', NULL, NULL, NULL, NULL, 7, NULL),
(74, 'BPH', 'Tenue de travail conforme, propre et adaptée au poste Coiffe enveloppat la totalité de la chevelure, vêtements de couleur claire, chaussures de sécurité, cache-barbe le cas échéant', NULL, NULL, NULL, NULL, 8, NULL),
(75, 'MAT', 'Le matériel de transport est propre et en bon état (cabine et caisson)', NULL, NULL, NULL, NULL, 7, NULL),
(76, 'DOC', 'Enregistrements des températures des produits en chargement effectués', NULL, NULL, NULL, NULL, 7, NULL),
(77, 'TEMP', 'Conformité des températures des produits en chargement  0-3°C pour les produits refroidis, max 10°C pour les préparations froides assemblées du matin', NULL, NULL, NULL, NULL, 7, NULL),
(78, 'DOC', 'Le nettoyage des camions et du matériel de transport est enregistré.', NULL, NULL, NULL, NULL, 7, NULL),
(79, 'BPH', 'Absence de bijoux Seule l\'alliance est tolérée', NULL, NULL, NULL, NULL, 8, NULL),
(80, 'BPH', 'Présence et usage correct des gants A réserver à des manipulations sensibles (tranchage…), obligatoire en cas de blessure', NULL, NULL, NULL, NULL, 8, NULL),
(81, 'MAT', 'Présence de lave-mains à commande non manuelle fonctionnels et accessibles', NULL, NULL, NULL, NULL, 8, NULL),
(82, 'BPH', 'Lave-mains approvisionnés en savon antiseptique et papier à usage unique Préciser la marque du savon bactéricide', NULL, NULL, NULL, NULL, 8, NULL),
(83, 'DOC', 'Présence d’un protocole de lavage des mains', NULL, NULL, NULL, NULL, 8, NULL),
(84, 'BPH', 'Comportement adapté contre les risques de contamination des denrées', NULL, NULL, NULL, NULL, 8, NULL),
(85, 'BPH', 'Absence d\'effets personnels en zone de production (habits, nourriture, sac…)', NULL, NULL, NULL, NULL, 8, NULL),
(86, 'BPH', 'Respect de la procédure de lavage des mains (fréquence et modalités)', NULL, NULL, NULL, NULL, 8, NULL),
(87, 'BPH', 'Absence de personne portant du vernis, des ongles longs ou des faux ongles', NULL, NULL, NULL, NULL, 8, NULL),
(88, 'BPH', 'Gestion satisfaisante du stockage du linge propre et sale Préciser le ieu de lavage du linge (sur site ou par société spécialisée) / le lieu de stockage du linge / la méthode de distribution.', NULL, NULL, NULL, NULL, 8, NULL),
(89, 'BPH', 'Gestion satisfaisante des tenues en cas de déplacement à l\'extérieur Changement de chaussure, retrait au minimum du tablier', NULL, NULL, NULL, NULL, 8, NULL),
(90, 'DOC', 'Formation satisfaisante du personnel (présentation des attestations de formation)', NULL, NULL, NULL, NULL, 8, NULL),
(91, 'MAT', 'Présence d\'une armoire ou d\'une trousse de secours accessible et correctement approvisionnée Au minimum : désinfectant, pansement, doigtier, masque', NULL, NULL, NULL, NULL, 8, NULL),
(92, 'MAT', 'Présence de kits visiteurs et port de ce kit pour toute personne présente en zone de production', NULL, NULL, NULL, NULL, 8, NULL),
(93, 'DOC', 'Disponibilité des certificats d\'aptitude à la manipulation des denrées alimentaires délivrés par la médecine du travail', NULL, NULL, NULL, NULL, 8, NULL),
(94, 'BPH', 'Rangement des locaux conforme (absence de stockage sol, de zone non accessible au nettoyage)', NULL, NULL, NULL, NULL, 9, NULL),
(95, 'PTE', 'Propreté des murs, plinthes et portes', NULL, NULL, NULL, NULL, 9, NULL),
(96, 'LOC', 'Abords de l\'établissement maintenus propres et ne constituant pas une source de contamination (nuisibles, détritus, végétation, absence de stockage envahissant, ...)', NULL, NULL, NULL, NULL, 9, NULL),
(97, 'LOC', 'Conception, superficie, sectorisation des locaux conforme à l\'activité', NULL, NULL, NULL, NULL, 9, NULL),
(98, 'LOC', 'Absence de dégradation significative des locaux  : état des murs, plafonds, sols, portes et fenêtres', NULL, NULL, NULL, NULL, 9, NULL),
(99, 'LOC', 'La circulation des flux  (denrées, personnel, matériel et déchets) ne constitue pas un risque de contamination croisée.', NULL, NULL, NULL, NULL, 9, NULL),
(100, 'LOC', 'Les surfaces dans les zones où les denrées alimentaires sont manipulées, sont lisses, lavables, résistantes à la corrosion et non toxiques (adaptées à l\'usage alimentaire). ', NULL, NULL, NULL, NULL, 9, NULL),
(101, 'PTE', 'Propreté sol, grille, caniveaux, siphon', NULL, NULL, NULL, NULL, 9, NULL),
(102, 'PTE', 'Propreté du plafond et des grilles d\'aération', NULL, NULL, NULL, NULL, 9, NULL),
(103, 'PTE', 'Propreté des interrupteurs, prises et poignées de portes', NULL, NULL, NULL, NULL, 9, NULL),
(104, 'PTE', 'Propreté et rangement des vestiaires du personnel', NULL, NULL, NULL, NULL, 9, NULL),
(105, 'PTE', 'Propreté et rangement des sanitaires du personnel', NULL, NULL, NULL, NULL, 9, NULL),
(106, 'LOC', 'Degraissage des hottes 1 fois/an (bons de passage disponibles)', NULL, NULL, NULL, NULL, 9, NULL),
(107, 'LOC', 'Ventilation suffisante (notamment en zone plonge/laverie et en zone cuisson) ', NULL, NULL, NULL, NULL, 9, NULL),
(108, 'LOC', 'Eclairage suffisant et protégé', NULL, NULL, NULL, NULL, 9, NULL),
(109, 'MAT', 'Matériels faciles à laver et à désinfecter', NULL, NULL, NULL, NULL, 10, NULL),
(110, 'MAT', 'Matériel ne risquant pas de contaminer les aliments (non poreux, non putrescibles, non corrodables, non cassé, apte au contact alimentaire)', NULL, NULL, NULL, NULL, 10, NULL),
(111, 'MAT', 'Lave mains et autres équipements de nettoyage désinfection en nombre suffisant', NULL, NULL, NULL, NULL, 10, NULL),
(112, 'MAT', ' Équipements en bon état de fonctionnement', NULL, NULL, NULL, NULL, 10, NULL),
(113, 'MAT', 'Présence de thermomètres en nombre suffisant, en bon état et hygiéniquement stockés', NULL, NULL, NULL, NULL, 10, NULL),
(114, 'DOC', 'Vérification bisannuelle des sondes thermomètre à 0 et 100°C Date de contrôle et écart éventuel notés sur le thermomètre', NULL, NULL, NULL, NULL, 10, NULL),
(115, 'MAT', 'Dimensionnement des équipements en regard de l’activité', NULL, NULL, NULL, NULL, 10, NULL),
(116, 'DOC', 'Maintenance du matériel et équipements (fiche de visite, contrat d’entretien, etc.)', NULL, NULL, NULL, NULL, 10, NULL),
(117, 'DOC', 'Maintenance des installations frigorifiques (fiche de visite, contrat d’entretien, etc.)', NULL, NULL, NULL, NULL, 10, NULL),
(118, 'MAT', 'Absence de givre au niveau des enceintes frigorifiques', NULL, NULL, NULL, NULL, 10, NULL),
(119, 'MAT', 'Fonctionnement des extracteurs (hottes, plonge)', NULL, NULL, NULL, NULL, 10, NULL),
(120, 'PTE', 'Propreté des filtres des extracteurs', NULL, NULL, NULL, NULL, 10, NULL),
(121, 'PTE', 'Propreté des enceintes réfrigérées', NULL, NULL, NULL, NULL, 10, NULL),
(122, 'PTE', 'Propreté du petit matériel de production (sondes, robots, mixeur, ouvre-boîte,…)', NULL, NULL, NULL, NULL, 10, NULL),
(123, 'PTE', 'Propreté du gros matériels de production (sauteuse, fours, pianos,…)', NULL, NULL, NULL, NULL, 10, NULL),
(124, 'PTE', 'Propreté et rangement des matériels au contact direct des aliments', NULL, NULL, NULL, NULL, 10, NULL),
(125, 'PTE', 'Propreté et rangement des matériels ne rentrant pas en contact avec les aliments', NULL, NULL, NULL, NULL, 10, NULL),
(126, 'PTE', 'Propreté du matériel à disposition des convives (fontaine à eau, machine à glace, micro-ondes)', NULL, NULL, NULL, NULL, 10, NULL),
(127, 'BPH', 'Absence de torchon', NULL, NULL, NULL, NULL, 10, NULL),
(128, 'DOC', 'Affichage des plans de Nettoyage & Désinfection à jour dans chaque zone', NULL, NULL, NULL, NULL, 11, NULL),
(129, 'LOC', 'Absence de zones inaccessibles au nettoyage', NULL, NULL, NULL, NULL, 11, NULL),
(130, 'DOC', 'Présence et pertinence des fiches d\'enregistrement des nettoyages', NULL, NULL, NULL, NULL, 11, NULL),
(131, 'BPH', 'Respect des procédures de Nettoyage & Désinfection   Temps d\'action, concentration, T°C', NULL, NULL, NULL, NULL, 11, NULL),
(132, 'DOC', 'Remplissage correct des fiches d\'enregistrement des nettoyages', NULL, NULL, NULL, NULL, 11, NULL),
(133, 'BPH', 'Utilisation de matériel de nettoyage adapté et en bon état', NULL, NULL, NULL, NULL, 11, NULL),
(134, 'PTE', 'Propreté du matériel de nettoyage  Machines à laver, éviers, raclette, balais…', NULL, NULL, NULL, NULL, 11, NULL),
(135, 'BPH', 'Présence de produits de nettoyage et de désinfection adaptés et référencés', NULL, NULL, NULL, NULL, 11, NULL),
(136, 'PTE', 'Propreté des machines à laver et bacs de plonge', NULL, NULL, NULL, NULL, 11, NULL),
(137, 'BPH', 'Entreposage isolé des produits d\'entretien et du matériels de nettoyage', NULL, NULL, NULL, NULL, 11, NULL),
(138, 'DOC', 'Présence des fiches de données de sécurité et fiches techniques des produits d\'entretien', NULL, NULL, NULL, NULL, 11, NULL),
(139, 'TEMP', 'Températures de lavage et rinçage des lave-vaisselles suffisantes (respectivement +55 et +80°C minimum)', NULL, NULL, NULL, NULL, 11, NULL),
(140, 'BPH', 'Stockage approprié de la vaisselle après nettoyage Récipients retournés, éviter les étagère sproches du sol', NULL, NULL, NULL, NULL, 11, NULL),
(141, 'BPH', 'Respect de la procédure de nettoyage et de stockage des planches à découper Récipients retournés, éviter les étagère sproches du sol', NULL, NULL, NULL, NULL, 11, NULL),
(142, 'BPH', 'Poubelles fermées, équipées de commande non manuelle en zone de production', NULL, NULL, NULL, NULL, 12, NULL),
(143, 'PTE', 'Poubelles propres et en bon état en zone de production', NULL, NULL, NULL, NULL, 12, NULL),
(144, 'BPH', 'Poubelles non surchargées', NULL, NULL, NULL, NULL, 12, NULL),
(145, 'PTE', 'Local poubelle propre  ', NULL, NULL, NULL, NULL, 12, NULL),
(146, 'DOC', 'Les huiles de friteuses sont récupérées par une société spécialisée. Les bons d\'enlèvement sont archivés.', NULL, NULL, NULL, NULL, 12, NULL),
(147, 'BPH', 'Tri des déchets conforme en production et distribution (biodéchets/emballages)', NULL, NULL, NULL, NULL, 12, NULL),
(148, 'BPH', 'Absence de nuisibles ou de traces de leur passage', NULL, NULL, NULL, NULL, 12, NULL),
(149, 'LOC', 'Les accès et autres ouvertures donnant sur l\'extérieur sont sécurisés (fermeture hermétique, siphons, …)', NULL, NULL, NULL, NULL, 12, NULL),
(150, 'BPH', 'Les appâts/destructeurs d\'insectes sont correctement positionnés et ne sont pas une source de contamination', NULL, NULL, NULL, NULL, 12, NULL),
(151, 'DOC', 'Contrat de dératisation et rapports d\'interventions disponibles', NULL, NULL, NULL, NULL, 12, NULL),
(152, 'LOC', 'Les fenêtres sont pourvues d\'écrans de protection amovibles contre les insectes (si elles donnent sur l\'extérieur).', NULL, NULL, NULL, NULL, 12, NULL),
(153, 'DOC', 'Présence du classeur nuisibles Plan des appâts, fiches techniques, FDS', NULL, NULL, NULL, NULL, 13, NULL),
(154, 'DOC', 'L\'établissement possède un Plan de Maîtrise Sanitaire à jour et consultable à tout moment.', NULL, NULL, NULL, NULL, 13, NULL),
(155, 'DOC', 'L\'équipe de cuisine verifie régulièrement le suivi du PMS (à chaque petite vacances) Compte-rendu de réunion à archiver', NULL, NULL, NULL, NULL, 13, NULL),
(156, 'DOC', 'Analyses microbiologiques effectuées par un laboratoire à la fréquence appropriée et traitement en cas de non-conformité < 200 r/j : tous les 2 mois : 2 produits + 3 surfaces 200-500 r/j : tous les 2 mois : 3 produits + 3 surfaces 500-1000 r/j : tous les mois : 3 produits + 5 surfaces > 1000 r/j : tous les mois : 4 produits + 5 surfaces', NULL, NULL, NULL, NULL, 13, NULL),
(157, 'DOC', 'Analyse de la potabilité de l\'eau effectuée au minimum une fois par an 2 fois/an pour les très gros établissements (>1000r/j)', NULL, NULL, NULL, NULL, 13, NULL),
(158, 'DOC', 'Respect des périodes d\'archivage des documents', NULL, NULL, NULL, NULL, 13, NULL),
(159, 'BPH', 'Les produits non-conformes sont clairement identifiés et isolés afin de prévenir un usage oinvolontaire', NULL, NULL, NULL, NULL, 13, NULL),
(160, 'DOC', 'Utilisation d\'une eau potable et présence dans le PMS d\'une attestation de raccordement au réseau public et d\'une copie de la facture d\'eau', NULL, NULL, NULL, NULL, 13, NULL),
(161, NULL, NULL, NULL, NULL, NULL, NULL, 27, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `test`
--

CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `indicateur` varchar(101) DEFAULT NULL,
  `question` varchar(338) DEFAULT NULL,
  `note` varchar(11) DEFAULT NULL,
  `obsEcart` varchar(255) DEFAULT NULL,
  `suggPlanAction` varchar(255) DEFAULT NULL,
  `picPath` varchar(255) DEFAULT NULL,
  `idTheme` int(10) NOT NULL,
  `etat` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Déchargement des données de la table `test`
--

INSERT INTO `test` (`id`, `indicateur`, `question`, `note`, `obsEcart`, `suggPlanAction`, `picPath`, `idTheme`, `etat`) VALUES
(1, 'TRAC', 'Fournisseurs de denrées d\'origine(s) animale(s) pourvus d\'un agrément sanitaire (ou dérogation)', '-2', NULL, NULL, NULL, 1, NULL),
(2, 'BPH', 'Limitation du temps d\'attente des denrées réfrigérées ou surgelées à température ambiante.', '0', NULL, NULL, NULL, 1, NULL),
(3, 'DOC', 'Affichage du document \"Température à réception\"', NULL, NULL, NULL, NULL, 1, NULL),
(4, 'MAT', 'Présence d\'un thermomètre à sonde et d\'un thermomètre laser en état de marche', NULL, NULL, NULL, NULL, 1, NULL),
(5, 'DOC', 'Respect de la procédure de contrôle réception avec enregistrement systématique  T°C, Date, Etat des emballages/produits', NULL, NULL, NULL, NULL, 1, NULL),
(6, 'DOC', 'Présence de fiche d\'anomalie à réception', NULL, NULL, NULL, NULL, 1, NULL),
(7, 'BPH', 'Port d\'une blouse adaptée pour la réception des marchandises', NULL, NULL, NULL, NULL, 1, NULL),
(8, 'NONE', 'Existe-t-il un protocole de chargement/déchargement pour chaque fournisseur ? Préciser le nombre et les noms des fournisseurs :', NULL, NULL, NULL, NULL, 1, NULL),
(9, 'BPH', 'Respect de la sectorisation par catégorie des produits stockés', NULL, NULL, NULL, NULL, 2, NULL),
(10, 'LOC', 'Enceintes frigorifiques non surchargées', NULL, NULL, NULL, NULL, 2, NULL),
(11, 'BPH', 'Rangement évitant les contaminations croisées  Denrées protégées, pas de produits au sol, pas de produits autres qu\'alimentaires, …', NULL, NULL, NULL, NULL, 2, NULL),
(12, 'BPH', 'Absence de défaut de fraicheur des produits Fruits et légumes moisis...', NULL, NULL, NULL, NULL, 2, NULL),
(13, 'BPH', 'Absence de conditionnements présentant des défauts Conserves cabossées, sous vide fuité...', NULL, NULL, NULL, NULL, 2, NULL),
(14, 'BPH', 'Absence de produits sans identification', NULL, NULL, NULL, NULL, 2, NULL),
(15, 'BPH', 'Absence de produits ayant une DLC dépassée en stock.', NULL, NULL, NULL, NULL, 2, NULL),
(16, 'BPH', 'Rotation des produits selon les dates', NULL, NULL, NULL, NULL, 2, NULL),
(17, 'BPH', 'Absence de produits ayant une DDM dépassée en stock.', NULL, NULL, NULL, NULL, 2, NULL),
(18, 'DOC', 'Enregitrement des T°C des enceintes réfrigérées conforme', NULL, NULL, NULL, NULL, 2, NULL),
(19, 'BPH', 'Respect de la procédure de contrôle des T°C des enceintes réfrigérées', NULL, NULL, NULL, NULL, 2, NULL),
(20, 'TEMP', 'Conformité des T° des enceintes frigorifiques positives - BOF : +3°C - Fruits et légumes : +8°C - Viande et charcuterie : +3°C - Frigo jour plats préparé : +3°C', NULL, NULL, NULL, NULL, 2, NULL),
(21, 'TEMP', 'Conformité des T° des enceintes frigorifiques négatives (-18°C)', NULL, NULL, NULL, NULL, 2, NULL),
(22, 'BPH', 'Absence de denrées congelées sur place  Sauf pain, dans contenant daté, DVS<15j', NULL, NULL, NULL, NULL, 2, NULL),
(23, 'MAT', 'Les différentes enceintes de froid sont équipées de thermomètres à lecture directe, d\'un thermomètre mobile ou d\'un système de surveillance (Alarme). ', NULL, NULL, NULL, NULL, 2, NULL),
(24, 'BPH', 'Respect des protocoles de déconditionnement (déboîtage, dessouvidage)', NULL, NULL, NULL, NULL, 3, NULL),
(25, 'DOC', 'Affichage du protocole de décontamination des végétaux ', NULL, NULL, NULL, NULL, 3, NULL),
(26, 'BPH', 'Respect du protocole de décontamination des végétaux consommés crus 30ml de solution chlorée à 2,6% dans 50L d\'eau', NULL, NULL, NULL, NULL, 3, NULL),
(27, 'BPH', 'Dispositions évitant les contaminations croisées', NULL, NULL, NULL, NULL, 3, NULL),
(28, 'TEMP', 'Maîtrise des temps d\'attente hors froid', NULL, NULL, NULL, NULL, 3, NULL),
(29, 'BPH', 'Progression logique des denrées dans la zone (entrée / traitement / sortie)', NULL, NULL, NULL, NULL, 3, NULL),
(30, 'TRAC', 'Conservation des éléments de traçabilité de tout produit déconditionné Numérisation de toutes les étiquettes', NULL, NULL, NULL, NULL, 3, NULL),
(31, 'BPH', 'Absence de décongélation à température ambiante', NULL, NULL, NULL, NULL, 3, NULL),
(32, 'BPH', 'Dispositions évitant les contaminations croisées', NULL, NULL, NULL, NULL, 4, NULL),
(33, 'BPH', 'Respect des bonnes pratiques d\'utilisation des œufs coquilles', NULL, NULL, NULL, NULL, 4, NULL),
(34, 'TEMP', 'Exposition limitée des produits semi-finis et finis en dehors des enceintes réfrigérées        30 min maximum', NULL, NULL, NULL, NULL, 4, NULL),
(35, 'TRAC', 'Les produits finis, en cours d\'utilisation et semi-finis sont protégés, identifiés et datés', NULL, NULL, NULL, NULL, 4, NULL),
(36, 'DOC', 'Disponibilité/affichage des durées de vie des produits déconditionnés', NULL, NULL, NULL, NULL, 4, NULL),
(37, 'BPH', 'Respect des durées de vie des produits décongelés  3 jours y compris le jour de mise en décongélation', NULL, NULL, NULL, NULL, 4, NULL),
(38, 'BPH', 'Respect des durées de vie des matières premières déconditionnées Voir PMS', NULL, NULL, NULL, NULL, 4, NULL),
(39, 'BPH', 'Respect des durées de vie des produits intermédiaires et produits finis', NULL, NULL, NULL, NULL, 4, NULL),
(40, 'BPH', 'Absence d\'emballage dans la zone de production froide (cartons, boites de conserve…)', NULL, NULL, NULL, NULL, 4, NULL),
(41, 'BPH', 'Conditionnements utilisés conformes (alimentarité, vétustée…)', NULL, NULL, NULL, NULL, 4, NULL),
(42, 'BPH', 'Dispositions évitant les contaminations croisées', NULL, NULL, NULL, NULL, 5, NULL),
(43, 'TRAC', 'Les produits finis, en cours d\'utilisation et semi-finis sont protégés, identifiés et datés. ', NULL, NULL, NULL, NULL, 5, NULL),
(44, 'BPH', 'Respect de la procédure de refroidissement ', NULL, NULL, NULL, NULL, 5, NULL),
(45, 'DOC', 'Enregitrement des refroidissements conforme', NULL, NULL, NULL, NULL, 5, NULL),
(46, 'BPH', 'Respect des durées de vie des produits intermédiaires et produits finis', NULL, NULL, NULL, NULL, 5, NULL),
(47, 'BPH', 'Respect de la procédure de réchauffage (matériel, méthode, enregistrement)', NULL, NULL, NULL, NULL, 5, NULL),
(48, 'DOC', 'Enregitrement des réchauffages conforme', NULL, NULL, NULL, NULL, 5, NULL),
(49, 'TEMP', 'Respect du maintien à température après cuisson (+63°C minimum)', NULL, NULL, NULL, NULL, 5, NULL),
(50, 'BPH', 'Sonde des cellules de refroidissement désinféctées avant utilisation', NULL, NULL, NULL, NULL, 5, NULL),
(51, 'BPH', 'Absence d\'emballage dans la zone de production chaude (cartons, boites de conserve…)', NULL, NULL, NULL, NULL, 5, NULL),
(52, 'BPH', 'Conditionnements utilisés conformes (alimentarité, vétustée…)', NULL, NULL, NULL, NULL, 5, NULL),
(53, 'BPH', 'Respect de la procédure de prélèvement des plats témoins Min 100g, en cours ou en fin de service', NULL, NULL, NULL, NULL, 6, NULL),
(54, 'BPH', 'Protection satisfaisante des produits présentés au service', NULL, NULL, NULL, NULL, 6, NULL),
(55, 'BPH', 'Respect de la procédure de gestion des plats témoins  Conservation 7j min., à +3°C, identifiés', NULL, NULL, NULL, NULL, 6, NULL),
(56, 'TRAC', 'Informations sur la provenance des viandes à disposition et à jour.', NULL, NULL, NULL, NULL, 6, NULL),
(57, 'TRAC', 'Informations sur les allergènes à disposition et à jour.', NULL, NULL, NULL, NULL, 6, NULL),
(58, 'BPH', 'Présence de la procédure et du matériel de contrôle des huiles de friture', NULL, NULL, NULL, NULL, 6, NULL),
(59, 'BPH', 'Respect de la procédure de contrôle des huiles de friture. Contrôle visuel ou à l\'aide de test après chaque utilisation', NULL, NULL, NULL, NULL, 6, NULL),
(60, 'DOC', 'Enregistrement des contrôles des huiles de friture conforme', NULL, NULL, NULL, NULL, 6, NULL),
(61, 'BPH', 'Utilisation des friteuses conforme T°C max 180°C, bains d\'huile différents pour frites/autre produits, filtration ', NULL, NULL, NULL, NULL, 6, NULL),
(62, 'BPH', 'Qualité de l\'huile conforme Composés polaires <25% (test par auditeur)', NULL, NULL, NULL, NULL, 6, NULL),
(63, 'TEMP', 'Conformité des T°C des préparations froides au moment du service  +10°C maximum', NULL, NULL, NULL, NULL, 6, NULL),
(64, 'TEMP', 'Conformité des T°C des préparations chaudes au moment du service  +63°C minimum', NULL, NULL, NULL, NULL, 6, NULL),
(65, 'TEMP', 'Conformité des températures des meubles de maintien  +90°C pour les bain-maries, +3°C pour les vitrines réfrigérées', NULL, NULL, NULL, NULL, 6, NULL),
(66, 'BPH', 'Respect de la procédure de contrôle des T°C en distribution (chaude et froide) En début et en cours de service ', NULL, NULL, NULL, NULL, 6, NULL),
(67, 'DOC', 'Enregistrement des contrôles de T°C en distribution conforme', NULL, NULL, NULL, NULL, 6, NULL),
(68, 'BPH', 'Respect du protocole de cuisson des steaks hachés  Cuisson minute, min. +65°C à coeur, en étuve 15-20min max', NULL, NULL, NULL, NULL, 6, NULL),
(69, 'BPH', 'Gestion des excedents   Jeter : tout reliquat de produit chaud et froids présentés à la vente Peuvent être resservis le lendemain : entrées et desserts conservés au frigo, plats chauds conservés en armoire et refroidis, laitages préemballés en vitrine', NULL, NULL, NULL, NULL, 6, NULL),
(70, 'BPH', 'Respect des durées de vie des produits finis J+3 max. sauf préparation hachée, tranchée et plats refroidis après service (J+1)', NULL, NULL, NULL, NULL, 6, NULL),
(71, 'TEMP', 'Les températures des équipements de transport sont conformes', NULL, NULL, NULL, NULL, 7, NULL),
(72, 'DOC', 'Les températures des équipements de transport sont contrôlées et enregistrées.', NULL, NULL, NULL, NULL, 7, NULL),
(73, 'BPH', 'Les denrées alimentaires sont transportées dans des équipements réservés et protégées de manière adéquate pendant le transport', NULL, NULL, NULL, NULL, 7, NULL),
(74, 'BPH', 'Tenue de travail conforme, propre et adaptée au poste Coiffe enveloppat la totalité de la chevelure, vêtements de couleur claire, chaussures de sécurité, cache-barbe le cas échéant', NULL, NULL, NULL, NULL, 8, NULL),
(75, 'MAT', 'Le matériel de transport est propre et en bon état (cabine et caisson)', NULL, NULL, NULL, NULL, 7, NULL),
(76, 'DOC', 'Enregistrements des températures des produits en chargement effectués', NULL, NULL, NULL, NULL, 7, NULL),
(77, 'TEMP', 'Conformité des températures des produits en chargement  0-3°C pour les produits refroidis, max 10°C pour les préparations froides assemblées du matin', NULL, NULL, NULL, NULL, 7, NULL),
(78, 'DOC', 'Le nettoyage des camions et du matériel de transport est enregistré.', NULL, NULL, NULL, NULL, 7, NULL),
(79, 'BPH', 'Absence de bijoux Seule l\'alliance est tolérée', NULL, NULL, NULL, NULL, 8, NULL),
(80, 'BPH', 'Présence et usage correct des gants A réserver à des manipulations sensibles (tranchage…), obligatoire en cas de blessure', NULL, NULL, NULL, NULL, 8, NULL),
(81, 'MAT', 'Présence de lave-mains à commande non manuelle fonctionnels et accessibles', NULL, NULL, NULL, NULL, 8, NULL),
(82, 'BPH', 'Lave-mains approvisionnés en savon antiseptique et papier à usage unique Préciser la marque du savon bactéricide', NULL, NULL, NULL, NULL, 8, NULL),
(83, 'DOC', 'Présence d’un protocole de lavage des mains', NULL, NULL, NULL, NULL, 8, NULL),
(84, 'BPH', 'Comportement adapté contre les risques de contamination des denrées', NULL, NULL, NULL, NULL, 8, NULL),
(85, 'BPH', 'Absence d\'effets personnels en zone de production (habits, nourriture, sac…)', NULL, NULL, NULL, NULL, 8, NULL),
(86, 'BPH', 'Respect de la procédure de lavage des mains (fréquence et modalités)', NULL, NULL, NULL, NULL, 8, NULL),
(87, 'BPH', 'Absence de personne portant du vernis, des ongles longs ou des faux ongles', NULL, NULL, NULL, NULL, 8, NULL),
(88, 'BPH', 'Gestion satisfaisante du stockage du linge propre et sale Préciser le ieu de lavage du linge (sur site ou par société spécialisée) / le lieu de stockage du linge / la méthode de distribution.', NULL, NULL, NULL, NULL, 8, NULL),
(89, 'BPH', 'Gestion satisfaisante des tenues en cas de déplacement à l\'extérieur Changement de chaussure, retrait au minimum du tablier', NULL, NULL, NULL, NULL, 8, NULL),
(90, 'DOC', 'Formation satisfaisante du personnel (présentation des attestations de formation)', NULL, NULL, NULL, NULL, 8, NULL),
(91, 'MAT', 'Présence d\'une armoire ou d\'une trousse de secours accessible et correctement approvisionnée Au minimum : désinfectant, pansement, doigtier, masque', NULL, NULL, NULL, NULL, 8, NULL),
(92, 'MAT', 'Présence de kits visiteurs et port de ce kit pour toute personne présente en zone de production', NULL, NULL, NULL, NULL, 8, NULL),
(93, 'DOC', 'Disponibilité des certificats d\'aptitude à la manipulation des denrées alimentaires délivrés par la médecine du travail', NULL, NULL, NULL, NULL, 8, NULL),
(94, 'BPH', 'Rangement des locaux conforme (absence de stockage sol, de zone non accessible au nettoyage)', NULL, NULL, NULL, NULL, 9, NULL),
(95, 'PTE', 'Propreté des murs, plinthes et portes', NULL, NULL, NULL, NULL, 9, NULL),
(96, 'LOC', 'Abords de l\'établissement maintenus propres et ne constituant pas une source de contamination (nuisibles, détritus, végétation, absence de stockage envahissant, ...)', NULL, NULL, NULL, NULL, 9, NULL),
(97, 'LOC', 'Conception, superficie, sectorisation des locaux conforme à l\'activité', NULL, NULL, NULL, NULL, 9, NULL),
(98, 'LOC', 'Absence de dégradation significative des locaux  : état des murs, plafonds, sols, portes et fenêtres', NULL, NULL, NULL, NULL, 9, NULL),
(99, 'LOC', 'La circulation des flux  (denrées, personnel, matériel et déchets) ne constitue pas un risque de contamination croisée.', NULL, NULL, NULL, NULL, 9, NULL),
(100, 'LOC', 'Les surfaces dans les zones où les denrées alimentaires sont manipulées, sont lisses, lavables, résistantes à la corrosion et non toxiques (adaptées à l\'usage alimentaire). ', NULL, NULL, NULL, NULL, 9, NULL),
(101, 'PTE', 'Propreté sol, grille, caniveaux, siphon', NULL, NULL, NULL, NULL, 9, NULL),
(102, 'PTE', 'Propreté du plafond et des grilles d\'aération', NULL, NULL, NULL, NULL, 9, NULL),
(103, 'PTE', 'Propreté des interrupteurs, prises et poignées de portes', NULL, NULL, NULL, NULL, 9, NULL),
(104, 'PTE', 'Propreté et rangement des vestiaires du personnel', NULL, NULL, NULL, NULL, 9, NULL),
(105, 'PTE', 'Propreté et rangement des sanitaires du personnel', NULL, NULL, NULL, NULL, 9, NULL),
(106, 'LOC', 'Degraissage des hottes 1 fois/an (bons de passage disponibles)', NULL, NULL, NULL, NULL, 9, NULL),
(107, 'LOC', 'Ventilation suffisante (notamment en zone plonge/laverie et en zone cuisson) ', NULL, NULL, NULL, NULL, 9, NULL),
(108, 'LOC', 'Eclairage suffisant et protégé', NULL, NULL, NULL, NULL, 9, NULL),
(109, 'MAT', 'Matériels faciles à laver et à désinfecter', NULL, NULL, NULL, NULL, 10, NULL),
(110, 'MAT', 'Matériel ne risquant pas de contaminer les aliments (non poreux, non putrescibles, non corrodables, non cassé, apte au contact alimentaire)', NULL, NULL, NULL, NULL, 10, NULL),
(111, 'MAT', 'Lave mains et autres équipements de nettoyage désinfection en nombre suffisant', NULL, NULL, NULL, NULL, 10, NULL),
(112, 'MAT', ' Équipements en bon état de fonctionnement', NULL, NULL, NULL, NULL, 10, NULL),
(113, 'MAT', 'Présence de thermomètres en nombre suffisant, en bon état et hygiéniquement stockés', NULL, NULL, NULL, NULL, 10, NULL),
(114, 'DOC', 'Vérification bisannuelle des sondes thermomètre à 0 et 100°C Date de contrôle et écart éventuel notés sur le thermomètre', NULL, NULL, NULL, NULL, 10, NULL),
(115, 'MAT', 'Dimensionnement des équipements en regard de l’activité', NULL, NULL, NULL, NULL, 10, NULL),
(116, 'DOC', 'Maintenance du matériel et équipements (fiche de visite, contrat d’entretien, etc.)', NULL, NULL, NULL, NULL, 10, NULL),
(117, 'DOC', 'Maintenance des installations frigorifiques (fiche de visite, contrat d’entretien, etc.)', NULL, NULL, NULL, NULL, 10, NULL),
(118, 'MAT', 'Absence de givre au niveau des enceintes frigorifiques', NULL, NULL, NULL, NULL, 10, NULL),
(119, 'MAT', 'Fonctionnement des extracteurs (hottes, plonge)', NULL, NULL, NULL, NULL, 10, NULL),
(120, 'PTE', 'Propreté des filtres des extracteurs', NULL, NULL, NULL, NULL, 10, NULL),
(121, 'PTE', 'Propreté des enceintes réfrigérées', NULL, NULL, NULL, NULL, 10, NULL),
(122, 'PTE', 'Propreté du petit matériel de production (sondes, robots, mixeur, ouvre-boîte,…)', NULL, NULL, NULL, NULL, 10, NULL),
(123, 'PTE', 'Propreté du gros matériels de production (sauteuse, fours, pianos,…)', NULL, NULL, NULL, NULL, 10, NULL),
(124, 'PTE', 'Propreté et rangement des matériels au contact direct des aliments', NULL, NULL, NULL, NULL, 10, NULL),
(125, 'PTE', 'Propreté et rangement des matériels ne rentrant pas en contact avec les aliments', NULL, NULL, NULL, NULL, 10, NULL),
(126, 'PTE', 'Propreté du matériel à disposition des convives (fontaine à eau, machine à glace, micro-ondes)', NULL, NULL, NULL, NULL, 10, NULL),
(127, 'BPH', 'Absence de torchon', NULL, NULL, NULL, NULL, 10, NULL),
(128, 'DOC', 'Affichage des plans de Nettoyage & Désinfection à jour dans chaque zone', NULL, NULL, NULL, NULL, 11, NULL),
(129, 'LOC', 'Absence de zones inaccessibles au nettoyage', NULL, NULL, NULL, NULL, 11, NULL),
(130, 'DOC', 'Présence et pertinence des fiches d\'enregistrement des nettoyages', NULL, NULL, NULL, NULL, 11, NULL),
(131, 'BPH', 'Respect des procédures de Nettoyage & Désinfection   Temps d\'action, concentration, T°C', NULL, NULL, NULL, NULL, 11, NULL),
(132, 'DOC', 'Remplissage correct des fiches d\'enregistrement des nettoyages', NULL, NULL, NULL, NULL, 11, NULL),
(133, 'BPH', 'Utilisation de matériel de nettoyage adapté et en bon état', NULL, NULL, NULL, NULL, 11, NULL),
(134, 'PTE', 'Propreté du matériel de nettoyage  Machines à laver, éviers, raclette, balais…', NULL, NULL, NULL, NULL, 11, NULL),
(135, 'BPH', 'Présence de produits de nettoyage et de désinfection adaptés et référencés', NULL, NULL, NULL, NULL, 11, NULL),
(136, 'PTE', 'Propreté des machines à laver et bacs de plonge', NULL, NULL, NULL, NULL, 11, NULL),
(137, 'BPH', 'Entreposage isolé des produits d\'entretien et du matériels de nettoyage', NULL, NULL, NULL, NULL, 11, NULL),
(138, 'DOC', 'Présence des fiches de données de sécurité et fiches techniques des produits d\'entretien', NULL, NULL, NULL, NULL, 11, NULL),
(139, 'TEMP', 'Températures de lavage et rinçage des lave-vaisselles suffisantes (respectivement +55 et +80°C minimum)', NULL, NULL, NULL, NULL, 11, NULL),
(140, 'BPH', 'Stockage approprié de la vaisselle après nettoyage Récipients retournés, éviter les étagère sproches du sol', NULL, NULL, NULL, NULL, 11, NULL),
(141, 'BPH', 'Respect de la procédure de nettoyage et de stockage des planches à découper Récipients retournés, éviter les étagère sproches du sol', NULL, NULL, NULL, NULL, 11, NULL),
(142, 'BPH', 'Poubelles fermées, équipées de commande non manuelle en zone de production', NULL, NULL, NULL, NULL, 12, NULL),
(143, 'PTE', 'Poubelles propres et en bon état en zone de production', NULL, NULL, NULL, NULL, 12, NULL),
(144, 'BPH', 'Poubelles non surchargées', NULL, NULL, NULL, NULL, 12, NULL),
(145, 'PTE', 'Local poubelle propre  ', NULL, NULL, NULL, NULL, 12, NULL),
(146, 'DOC', 'Les huiles de friteuses sont récupérées par une société spécialisée. Les bons d\'enlèvement sont archivés.', NULL, NULL, NULL, NULL, 12, NULL),
(147, 'BPH', 'Tri des déchets conforme en production et distribution (biodéchets/emballages)', NULL, NULL, NULL, NULL, 12, NULL),
(148, 'BPH', 'Absence de nuisibles ou de traces de leur passage', NULL, NULL, NULL, NULL, 12, NULL),
(149, 'LOC', 'Les accès et autres ouvertures donnant sur l\'extérieur sont sécurisés (fermeture hermétique, siphons, …)', NULL, NULL, NULL, NULL, 12, NULL),
(150, 'BPH', 'Les appâts/destructeurs d\'insectes sont correctement positionnés et ne sont pas une source de contamination', NULL, NULL, NULL, NULL, 12, NULL),
(151, 'DOC', 'Contrat de dératisation et rapports d\'interventions disponibles', NULL, NULL, NULL, NULL, 12, NULL),
(152, 'LOC', 'Les fenêtres sont pourvues d\'écrans de protection amovibles contre les insectes (si elles donnent sur l\'extérieur).', NULL, NULL, NULL, NULL, 12, NULL),
(153, 'DOC', 'Présence du classeur nuisibles Plan des appâts, fiches techniques, FDS', NULL, NULL, NULL, NULL, 13, NULL),
(154, 'DOC', 'L\'établissement possède un Plan de Maîtrise Sanitaire à jour et consultable à tout moment.', NULL, NULL, NULL, NULL, 13, NULL),
(155, 'DOC', 'L\'équipe de cuisine verifie régulièrement le suivi du PMS (à chaque petite vacances) Compte-rendu de réunion à archiver', NULL, NULL, NULL, NULL, 13, NULL),
(156, 'DOC', 'Analyses microbiologiques effectuées par un laboratoire à la fréquence appropriée et traitement en cas de non-conformité < 200 r/j : tous les 2 mois : 2 produits + 3 surfaces 200-500 r/j : tous les 2 mois : 3 produits + 3 surfaces 500-1000 r/j : tous les mois : 3 produits + 5 surfaces > 1000 r/j : tous les mois : 4 produits + 5 surfaces', NULL, NULL, NULL, NULL, 13, NULL),
(157, 'DOC', 'Analyse de la potabilité de l\'eau effectuée au minimum une fois par an 2 fois/an pour les très gros établissements (>1000r/j)', NULL, NULL, NULL, NULL, 13, NULL),
(158, 'DOC', 'Respect des périodes d\'archivage des documents', NULL, NULL, NULL, NULL, 13, NULL),
(159, 'BPH', 'Les produits non-conformes sont clairement identifiés et isolés afin de prévenir un usage oinvolontaire', NULL, NULL, NULL, NULL, 13, NULL),
(160, 'DOC', 'Utilisation d\'une eau potable et présence dans le PMS d\'une attestation de raccordement au réseau public et d\'une copie de la facture d\'eau', NULL, NULL, NULL, NULL, 13, NULL),
(161, NULL, NULL, NULL, NULL, NULL, NULL, 27, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `themeaudit`
--

CREATE TABLE `themeaudit` (
  `id` int(11) NOT NULL,
  `nomThemeAudit` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `themeaudit`
--

INSERT INTO `themeaudit` (`id`, `nomThemeAudit`) VALUES
(1, '1. Réception des Matières premières'),
(2, '2. Stockage des Matières Premières '),
(3, '3. Légumerie et Déboitage'),
(4, '4. Préparations froides'),
(5, '5. Préparations chaudes'),
(6, '6. Distribution'),
(7, '7. Transport (Uniquement Cuisine Centrale)'),
(8, '8. Hygiene du personnel'),
(9, '9. Locaux'),
(10, '10. Materiels et équipements'),
(11, '11. Nettoyage & Désinfection'),
(12, '12. Dechets et nuisibles'),
(13, '13. Vérification du PMS et Amélioration continue'),
(27, 'NULL');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `entreprise`
--
ALTER TABLE `entreprise`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `modelaudit`
--
ALTER TABLE `modelaudit`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `questionaudit`
--
ALTER TABLE `questionaudit`
  ADD PRIMARY KEY (`id`),
  ADD KEY `quesTheme` (`idTheme`);

--
-- Index pour la table `test`
--
ALTER TABLE `test`
  ADD PRIMARY KEY (`id`),
  ADD KEY `quesTheme` (`idTheme`);

--
-- Index pour la table `themeaudit`
--
ALTER TABLE `themeaudit`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `entreprise`
--
ALTER TABLE `entreprise`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- AUTO_INCREMENT pour la table `modelaudit`
--
ALTER TABLE `modelaudit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `questionaudit`
--
ALTER TABLE `questionaudit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=163;

--
-- AUTO_INCREMENT pour la table `test`
--
ALTER TABLE `test`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT pour la table `themeaudit`
--
ALTER TABLE `themeaudit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `questionaudit`
--
ALTER TABLE `questionaudit`
  ADD CONSTRAINT `quesTheme` FOREIGN KEY (`idTheme`) REFERENCES `themeaudit` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
