-- MySQL dump 10.13  Distrib 8.0.22, for macos10.15 (x86_64)
--
-- Host: 127.0.0.1    Database: coredembcn
-- ------------------------------------------------------
-- Server version	8.0.22

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `__relations`
--

DROP TABLE IF EXISTS `__relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `__relations` (
  `sChild` varchar(50) DEFAULT NULL,
  `sParent` varchar(50) DEFAULT NULL,
  `sLinkColumn` varchar(50) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `__relations`
--

LOCK TABLES `__relations` WRITE;
/*!40000 ALTER TABLE `__relations` DISABLE KEYS */;
INSERT INTO `__relations` VALUES ('_trials','_subjects','idSubject'),('kinematics','_trials','idTrial'),('_neurons','_trials','idTrial'),('lfp','_trials','idTrial'),('oculometry','_trials','idTrial'),('_neurons','electrodes','idElectrode');
/*!40000 ALTER TABLE `__relations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `__signals`
--

DROP TABLE IF EXISTS `__signals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `__signals` (
  `idSignal` int DEFAULT NULL,
  `sName` text,
  `sTable` text,
  `sType` text,
  `sColumn` text,
  `nColumnNum` int DEFAULT NULL,
  `sUnits` text,
  `nRate` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `__signals`
--

LOCK TABLES `__signals` WRITE;
/*!40000 ALTER TABLE `__signals` DISABLE KEYS */;
INSERT INTO `__signals` VALUES (1,'nPosX','kinematics','','nPosX',4,'',0),(2,'nPosY','kinematics','','nPosY',5,'',0),(3,'nPosZ','kinematics','','nPosZ',6,'',0),(4,'tKinTime','kinematics','','tTime',3,'',0),(5,'eyeLx','oculometry','','eyeLx',4,'',0),(6,'eyeLy','oculometry','','eyeLy',5,'',0),(7,'eyeRx','oculometry','','eyeRx',6,'',0),(8,'eyeRy','oculometry','','eyeRy',7,'',0),(9,'pupilL','oculometry','','pupilL',8,'',0),(10,'pupilR','oculometry','','pupilR',9,'',0),(11,'eyeTime','oculometry','','eyeTime',3,'',0);
/*!40000 ALTER TABLE `__signals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `_subjects`
--

DROP TABLE IF EXISTS `_subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_subjects` (
  `idSubject` int unsigned NOT NULL AUTO_INCREMENT,
  `sAName` varchar(50) DEFAULT NULL,
  `sFullName` varchar(50) DEFAULT NULL,
  `nAge` int DEFAULT NULL,
  `sGender` varchar(50) DEFAULT NULL,
  `sHanded` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`idSubject`)
) ENGINE=MyISAM AUTO_INCREMENT=124 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_subjects`
--

LOCK TABLES `_subjects` WRITE;
/*!40000 ALTER TABLE `_subjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `_subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `_trials`
--

DROP TABLE IF EXISTS `_trials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `_trials` (
  `idTrial` int unsigned NOT NULL AUTO_INCREMENT,
  `nTrial` int DEFAULT NULL,
  `idSubject` int DEFAULT NULL,
  `nHorizon` int DEFAULT NULL,
  `feedback_visible` int DEFAULT NULL,
  `task_order` int DEFAULT NULL,
  `block_withinHor` int DEFAULT NULL,
  `dDate` datetime DEFAULT NULL,
  `nTimeEvent9` int DEFAULT NULL,
  `nTimeEvent10` int DEFAULT NULL,
  `nTimeEvent18` int DEFAULT NULL,
  `nTimeEvent20` int DEFAULT NULL,
  `nTimeEvent30` int DEFAULT NULL,
  `nTimeEvent40` int DEFAULT NULL,
  `nTimeEvent50` int DEFAULT NULL,
  `nTimeEvent60` int DEFAULT NULL,
  `nTimeEvent80` int DEFAULT NULL,
  `nTimeEvent81` int DEFAULT NULL,
  `nTimeEvent85` int DEFAULT NULL,
  `nTimeEvent86` int DEFAULT NULL,
  `nTimeEvent87` int DEFAULT NULL,
  `nTimeEvent90` int DEFAULT NULL,
  `nTimeEvent95` int DEFAULT NULL,
  `nTimeEvent999` int DEFAULT NULL,
  `trialError` int DEFAULT NULL,
  `choice_position` double DEFAULT NULL,
  `reward2` double DEFAULT NULL,
  `stimulus_l` double DEFAULT NULL,
  `reward3` double DEFAULT NULL,
  `stimulus_r` double DEFAULT NULL,
  `reward_episode` double DEFAULT NULL,
  `av_choice1` double DEFAULT NULL,
  `av_choice2` double DEFAULT NULL,
  `av_choice3` double DEFAULT NULL,
  `av_choice4` double DEFAULT NULL,
  `av_choice5` double DEFAULT NULL,
  `av_choice6` double DEFAULT NULL,
  `av_choice7` double DEFAULT NULL,
  `av_choice8` double DEFAULT NULL,
  `VisualDiscimination` double DEFAULT NULL,
  PRIMARY KEY (`idTrial`),
  KEY `indexTrialTrial` (`nTrial`,`idSubject`)
) ENGINE=MyISAM AUTO_INCREMENT=350258 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `_trials`
--

LOCK TABLES `_trials` WRITE;
/*!40000 ALTER TABLE `_trials` DISABLE KEYS */;
/*!40000 ALTER TABLE `_trials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kinematics`
--

DROP TABLE IF EXISTS `kinematics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kinematics` (
  `idKinematics` int NOT NULL AUTO_INCREMENT,
  `idTrial` int DEFAULT NULL,
  `tTime` int DEFAULT NULL,
  `nPosX` double DEFAULT NULL,
  `nPosY` double DEFAULT NULL,
  `nPosZ` double DEFAULT NULL,
  `nButton` int DEFAULT NULL,
  PRIMARY KEY (`idKinematics`),
  KEY `indexKinTrials` (`idTrial`)
) ENGINE=MyISAM AUTO_INCREMENT=151228159 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kinematics`
--

LOCK TABLES `kinematics` WRITE;
/*!40000 ALTER TABLE `kinematics` DISABLE KEYS */;
/*!40000 ALTER TABLE `kinematics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oculometry`
--

DROP TABLE IF EXISTS `oculometry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oculometry` (
  `idoculometry` int NOT NULL AUTO_INCREMENT,
  `idTrial` int unsigned DEFAULT NULL,
  `eyeTime` int DEFAULT NULL,
  `eyeLx` double DEFAULT NULL,
  `eyeLy` double DEFAULT NULL,
  `eyeRx` double DEFAULT NULL,
  `eyeRy` double DEFAULT NULL,
  `pupilL` double DEFAULT NULL,
  `pupilR` double DEFAULT NULL,
  PRIMARY KEY (`idoculometry`),
  KEY `indexOcuTrials` (`idTrial`)
) ENGINE=InnoDB AUTO_INCREMENT=2598797 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oculometry`
--

LOCK TABLES `oculometry` WRITE;
/*!40000 ALTER TABLE `oculometry` DISABLE KEYS */;
/*!40000 ALTER TABLE `oculometry` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-02-25 14:52:49
