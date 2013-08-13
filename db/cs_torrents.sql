-- MySQL dump 9.11
--
-- Host: localhost    Database: cs_torrents
-- ------------------------------------------------------
-- Server version	4.0.24_Debian-10sarge2-log

--
-- Table structure for table `torrent_bans`
--

CREATE TABLE `torrent_bans` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `ipstart` int(10) unsigned NOT NULL default '0',
  `ipend` int(10) unsigned NOT NULL default '0',
  `reason` varchar(255) NOT NULL default '',
  `date` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `ip_unique` (`ipstart`,`ipend`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_bans`
--


--
-- Table structure for table `torrent_categories`
--

CREATE TABLE `torrent_categories` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(30) NOT NULL default '',
  `sort_index` int(10) unsigned NOT NULL default '0',
  `image` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `sort_index` (`sort_index`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_categories`
--

INSERT INTO `torrent_categories` VALUES (1,'Movies',10,'film.jpg');
INSERT INTO `torrent_categories` VALUES (2,'Music',20,'music.jpg');
INSERT INTO `torrent_categories` VALUES (3,'TV',30,'tv.jpg');
INSERT INTO `torrent_categories` VALUES (4,'Games',40,'games.jpg');
INSERT INTO `torrent_categories` VALUES (5,'PC Software',50,'apps.jpg');
INSERT INTO `torrent_categories` VALUES (6,'Linux Software',70,'linux.jpg');
INSERT INTO `torrent_categories` VALUES (7,'Mac Software',60,'macosx.jpg');
INSERT INTO `torrent_categories` VALUES (8,'Pictures',80,'pics.jpg');
INSERT INTO `torrent_categories` VALUES (9,'Anime',90,'anime.jpg');
INSERT INTO `torrent_categories` VALUES (10,'Fun',100,'comics.jpg');
INSERT INTO `torrent_categories` VALUES (11,'Books',110,'books.jpg');
INSERT INTO `torrent_categories` VALUES (12,'Porn',200,'pr0n.jpg');

--
-- Table structure for table `torrent_comments`
--

CREATE TABLE `torrent_comments` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `user` int(10) unsigned NOT NULL default '0',
  `torrent` int(10) unsigned NOT NULL default '0',
  `added` datetime NOT NULL default '0000-00-00 00:00:00',
  `text` text NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user` (`user`),
  KEY `torrent` (`torrent`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_comments`
--

INSERT INTO `torrent_comments` VALUES (1,2,5,'2006-09-09 22:18:39','hi hi  :lol: ');

--
-- Table structure for table `torrent_comments_notify`
--

CREATE TABLE `torrent_comments_notify` (
  `torrent` int(11) NOT NULL default '0',
  `user` int(11) NOT NULL default '0',
  `status` enum('active','stopped') NOT NULL default 'active',
  PRIMARY KEY  (`torrent`,`user`),
  KEY `torrent` (`torrent`,`status`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_comments_notify`
--

INSERT INTO `torrent_comments_notify` VALUES (5,2,'active');
INSERT INTO `torrent_comments_notify` VALUES (3,2,'active');
INSERT INTO `torrent_comments_notify` VALUES (6,2,'active');
INSERT INTO `torrent_comments_notify` VALUES (7,2,'active');
INSERT INTO `torrent_comments_notify` VALUES (8,2,'active');

--
-- Table structure for table `torrent_complaints`
--

CREATE TABLE `torrent_complaints` (
  `torrent` int(15) unsigned NOT NULL default '0',
  `user` int(11) unsigned NOT NULL default '0',
  `host` varchar(60) NOT NULL default '',
  `datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  `score` smallint(1) unsigned zerofill NOT NULL default '0',
  PRIMARY KEY  (`torrent`,`user`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_complaints`
--


--
-- Table structure for table `torrent_config`
--

CREATE TABLE `torrent_config` (
  `sitename` varchar(255) NOT NULL default '',
  `siteurl` varchar(255) NOT NULL default '',
  `cookiedomain` varchar(30) NOT NULL default '',
  `cookiepath` varchar(60) NOT NULL default '',
  `admin_email` varchar(60) NOT NULL default '',
  `language` varchar(15) NOT NULL default '',
  `theme` varchar(255) NOT NULL default '',
  `welcome_message` longtext,
  `announce_text` varchar(255) default NULL,
  `allow_html` enum('true','false') NOT NULL default 'true',
  `rewrite_engine` enum('true','false') NOT NULL default 'true',
  `torrent_prefix` varchar(255) default NULL,
  `torrent_per_page` int(10) unsigned NOT NULL default '10',
  `onlysearch` enum('true','false') NOT NULL default 'true',
  `max_torrent_size` int(11) unsigned NOT NULL default '0',
  `announce_interval_min` int(10) unsigned NOT NULL default '0',
  `announce_interval` int(10) unsigned NOT NULL default '0',
  `dead_torrent_interval` int(10) unsigned NOT NULL default '0',
  `minvotes` smallint(5) unsigned NOT NULL default '0',
  `time_tracker_update` int(10) unsigned NOT NULL default '0',
  `best_limit` smallint(5) unsigned NOT NULL default '0',
  `down_limit` smallint(5) unsigned NOT NULL default '0',
  `torrent_complaints` enum('true','false') NOT NULL default 'false',
  `torrent_global_privacy` enum('true','false') NOT NULL default 'true',
  `disclaimer_check` enum('true','false') NOT NULL default 'false',
  `gfx_check` enum('true','false') NOT NULL default 'true',
  `upload_level` enum('all','user','premium') NOT NULL default 'user',
  `download_level` enum('all','user','premium') NOT NULL default 'all',
  `announce_level` enum('all','user') NOT NULL default 'all',
  `max_num_file` smallint(5) unsigned NOT NULL default '0',
  `max_share_size` bigint(8) unsigned NOT NULL default '0',
  `min_size_seed` mediumint(8) unsigned NOT NULL default '0',
  `min_share_seed` bigint(8) unsigned NOT NULL default '0',
  `global_min_ratio` float unsigned NOT NULL default '0',
  `autoscrape` enum('true','false') NOT NULL default 'true',
  `min_num_seed_e` smallint(5) unsigned NOT NULL default '0',
  `min_size_seed_e` bigint(8) unsigned NOT NULL default '0',
  `minupload_size_file` int(10) unsigned NOT NULL default '0',
  `allow_backup_tracker` enum('true','false') NOT NULL default 'false',
  `stealthmode` enum('true','false') NOT NULL default 'true',
  `version` varchar(5) NOT NULL default ''
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_config`
--

INSERT INTO `torrent_config` VALUES ('CS','http://no.hysing.org/rvb/cst','hysing.org','/rvb/cst','robert.bjarnason@gmail.com','english','Hypercube','Welcome to this Administration site for the Content Store BitTorrent Delivery system<br /><br />Thank you for you cooperation!<br /><br />Goodbye!','','true','true','',10,'true',0,0,0,0,0,0,0,0,'true','true','true','true','premium','user','user',0,0,0,0,0,'true',0,0,0,'false','false','0.6');

--
-- Table structure for table `torrent_download_completed`
--

CREATE TABLE `torrent_download_completed` (
  `user` int(11) unsigned NOT NULL default '0',
  `torrent` int(15) unsigned NOT NULL default '0',
  `completed` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`user`,`torrent`),
  KEY `torrent` (`torrent`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_download_completed`
--

INSERT INTO `torrent_download_completed` VALUES (2,5,'2006-09-09 22:08:29');
INSERT INTO `torrent_download_completed` VALUES (2,3,'2006-09-09 22:18:05');
INSERT INTO `torrent_download_completed` VALUES (4,5,'2006-09-10 06:38:03');
INSERT INTO `torrent_download_completed` VALUES (5,6,'2006-09-10 09:18:28');
INSERT INTO `torrent_download_completed` VALUES (5,7,'2006-09-10 09:52:55');
INSERT INTO `torrent_download_completed` VALUES (8,8,'2006-09-10 22:06:25');
INSERT INTO `torrent_download_completed` VALUES (9,5,'2006-09-11 00:14:15');
INSERT INTO `torrent_download_completed` VALUES (10,8,'2006-09-11 02:31:11');
INSERT INTO `torrent_download_completed` VALUES (12,8,'2006-09-11 10:46:24');
INSERT INTO `torrent_download_completed` VALUES (14,8,'2006-09-12 20:48:27');
INSERT INTO `torrent_download_completed` VALUES (16,5,'2006-09-13 23:18:24');
INSERT INTO `torrent_download_completed` VALUES (16,8,'2006-09-13 23:23:27');

--
-- Table structure for table `torrent_files`
--

CREATE TABLE `torrent_files` (
  `id` int(20) unsigned NOT NULL auto_increment,
  `torrent` int(15) unsigned NOT NULL default '0',
  `filename` varchar(255) NOT NULL default '',
  `size` bigint(20) unsigned NOT NULL default '0',
  `md5sum` varchar(32) default NULL,
  `ed2k` varchar(255) default NULL,
  `magnet` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `torrent_2` (`torrent`,`filename`),
  KEY `torrent` (`torrent`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_files`
--

INSERT INTO `torrent_files` VALUES (5,5,'IMGP1834.JPG',2329327,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (3,3,'Laugardalur.JPG',2568129,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (6,6,'field-trip-west-siberia.avi',471251774,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (7,6,'field-trip-west-siberia.flv',6566169,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (8,6,'field-trip-west-siberia.txt',4697,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (9,6,'screenshot.png',139555,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (10,7,'dwarf.jpg',34487,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (11,7,'star-wreck-in-the-pirkinning.txt',2554,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (12,7,'star_wreck_in_the_pirkinning_subtitled_xvid.avi',567558236,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (13,7,'star_wreck_in_the_pirkinning_subtitled_xvid.flv',34207343,NULL,NULL,NULL);
INSERT INTO `torrent_files` VALUES (14,8,'IMGP1839.JPG',2004451,NULL,NULL,NULL);

--
-- Table structure for table `torrent_filter`
--

CREATE TABLE `torrent_filter` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `keyword` varchar(50) NOT NULL default '',
  `reason` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `keyword` (`keyword`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_filter`
--


--
-- Table structure for table `torrent_online_users`
--

CREATE TABLE `torrent_online_users` (
  `id` int(60) unsigned NOT NULL default '0',
  `page` varchar(255) NOT NULL default '',
  `logged_in` datetime NOT NULL default '0000-00-00 00:00:00',
  `last_action` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_online_users`
--

INSERT INTO `torrent_online_users` VALUES (2,'index.php','2006-09-15 01:47:13','2006-09-17 14:17:31');

--
-- Table structure for table `torrent_peers`
--

CREATE TABLE `torrent_peers` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `uid` int(11) unsigned NOT NULL default '0',
  `torrent` int(10) unsigned NOT NULL default '0',
  `peer_id` varchar(20) binary NOT NULL default '',
  `unique_id` varchar(20) default NULL,
  `ip` int(10) unsigned NOT NULL default '0',
  `port` smallint(5) unsigned NOT NULL default '0',
  `real_ip` int(10) unsigned NOT NULL default '0',
  `uploaded` bigint(20) unsigned NOT NULL default '0',
  `downloaded` bigint(20) unsigned NOT NULL default '0',
  `download_speed` int(11) unsigned NOT NULL default '0',
  `upload_speed` int(11) unsigned NOT NULL default '0',
  `to_go` bigint(20) unsigned NOT NULL default '0',
  `seeder` enum('yes','no') NOT NULL default 'no',
  `started` datetime NOT NULL default '0000-00-00 00:00:00',
  `last_action` datetime NOT NULL default '0000-00-00 00:00:00',
  `connectable` enum('yes','no') NOT NULL default 'yes',
  `client` varchar(60) default NULL,
  `version` varchar(10) NOT NULL default '',
  `user_agent` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `torrent_peer_id` (`torrent`,`peer_id`),
  UNIQUE KEY `torrent_3` (`torrent`,`unique_id`),
  KEY `torrent` (`torrent`),
  KEY `last_action` (`last_action`),
  KEY `torrent_2` (`torrent`,`seeder`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_peers`
--

INSERT INTO `torrent_peers` VALUES (101,16,5,'-UT1600-⁄Å¢Ü∏) 7∑','49E70261',1504190376,54315,1504190376,3066607,0,0,0,0,'yes','2006-09-17 19:08:07','2006-09-17 19:08:07','no','&micro;Torrent','1.6.0.0','uTorrent/1600');

--
-- Table structure for table `torrent_privacy_backup`
--

CREATE TABLE `torrent_privacy_backup` (
  `master` int(11) unsigned NOT NULL default '0',
  `slave` int(11) NOT NULL default '0',
  `torrent` int(11) NOT NULL default '0',
  `status` enum('pending','denied','granted') NOT NULL default 'pending',
  PRIMARY KEY  (`slave`,`torrent`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_privacy_backup`
--


--
-- Table structure for table `torrent_privacy_file`
--

CREATE TABLE `torrent_privacy_file` (
  `master` int(11) unsigned NOT NULL default '0',
  `slave` int(11) unsigned NOT NULL default '0',
  `torrent` int(15) unsigned NOT NULL default '0',
  `status` enum('pending','denied','granted') NOT NULL default 'pending',
  PRIMARY KEY  (`slave`,`torrent`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_privacy_file`
--


--
-- Table structure for table `torrent_privacy_global`
--

CREATE TABLE `torrent_privacy_global` (
  `master` int(11) unsigned NOT NULL default '0',
  `slave` int(11) unsigned NOT NULL default '0',
  `status` enum('blacklist','whitelist') NOT NULL default 'whitelist',
  PRIMARY KEY  (`master`,`slave`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_privacy_global`
--


--
-- Table structure for table `torrent_private_messages`
--

CREATE TABLE `torrent_private_messages` (
  `id` int(20) unsigned zerofill NOT NULL auto_increment,
  `sender` int(11) unsigned NOT NULL default '0',
  `recipient` int(11) unsigned NOT NULL default '0',
  `subject` varchar(255) NOT NULL default '',
  `text` longtext NOT NULL,
  `is_read` enum('true','false') NOT NULL default 'false',
  `sent` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  KEY `from` (`sender`),
  KEY `to` (`recipient`),
  FULLTEXT KEY `text` (`text`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_private_messages`
--


--
-- Table structure for table `torrent_private_messages_blacklist`
--

CREATE TABLE `torrent_private_messages_blacklist` (
  `master` int(11) unsigned NOT NULL default '0',
  `slave` int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (`master`,`slave`),
  KEY `master` (`master`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_private_messages_blacklist`
--

INSERT INTO `torrent_private_messages_blacklist` VALUES (2,2);

--
-- Table structure for table `torrent_private_messages_bookmarks`
--

CREATE TABLE `torrent_private_messages_bookmarks` (
  `master` int(11) unsigned NOT NULL default '0',
  `slave` int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (`master`,`slave`),
  KEY `master` (`master`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_private_messages_bookmarks`
--


--
-- Table structure for table `torrent_ratings`
--

CREATE TABLE `torrent_ratings` (
  `torrent` int(10) unsigned NOT NULL default '0',
  `user` int(10) unsigned NOT NULL default '0',
  `rating` tinyint(3) unsigned NOT NULL default '0',
  `added` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`torrent`,`user`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_ratings`
--


--
-- Table structure for table `torrent_seeder_notify`
--

CREATE TABLE `torrent_seeder_notify` (
  `torrent` int(11) NOT NULL default '0',
  `user` int(11) NOT NULL default '0',
  `status` enum('active','stopped') NOT NULL default 'active',
  PRIMARY KEY  (`torrent`,`user`),
  KEY `contacts` (`torrent`,`status`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_seeder_notify`
--

INSERT INTO `torrent_seeder_notify` VALUES (5,2,'stopped');
INSERT INTO `torrent_seeder_notify` VALUES (3,2,'stopped');
INSERT INTO `torrent_seeder_notify` VALUES (6,2,'stopped');
INSERT INTO `torrent_seeder_notify` VALUES (7,2,'active');
INSERT INTO `torrent_seeder_notify` VALUES (8,2,'stopped');

--
-- Table structure for table `torrent_shouts`
--

CREATE TABLE `torrent_shouts` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
  `user` int(10) unsigned NOT NULL default '0',
  `text` varchar(255) NOT NULL default '',
  `posted` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `anti_flood` (`user`,`text`),
  KEY `posted` (`posted`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_shouts`
--


--
-- Table structure for table `torrent_smiles`
--

CREATE TABLE `torrent_smiles` (
  `id` int(5) unsigned NOT NULL auto_increment,
  `code` varchar(15) NOT NULL default '',
  `file` varchar(30) NOT NULL default '',
  `alt` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `code` (`code`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_smiles`
--

INSERT INTO `torrent_smiles` VALUES (1,':)','icon_smile.gif','Smile');
INSERT INTO `torrent_smiles` VALUES (2,':-)','icon_smile.gif','Smile');
INSERT INTO `torrent_smiles` VALUES (3,':smile:','icon_smile.gif','Smile');
INSERT INTO `torrent_smiles` VALUES (4,':(','icon_sad.gif','Sad');
INSERT INTO `torrent_smiles` VALUES (5,':-(','icon_sad.gif','Sad');
INSERT INTO `torrent_smiles` VALUES (6,':sad:','icon_sad.gif','Sad');
INSERT INTO `torrent_smiles` VALUES (7,':D','icon_biggrin.gif','Very Happy');
INSERT INTO `torrent_smiles` VALUES (8,':-D','icon_biggrin.gif','Very Happy');
INSERT INTO `torrent_smiles` VALUES (9,':grin:','icon_biggrin.gif','Very Happy');
INSERT INTO `torrent_smiles` VALUES (10,';-)','icon_wink.gif','Wink');
INSERT INTO `torrent_smiles` VALUES (11,';)','icon_wink.gif','Wink');
INSERT INTO `torrent_smiles` VALUES (12,':wink:','icon_wink.gif','Wink');
INSERT INTO `torrent_smiles` VALUES (13,':o','icon_surprised.gif','Surprised');
INSERT INTO `torrent_smiles` VALUES (14,':-o','icon_surprised.gif','Surprised');
INSERT INTO `torrent_smiles` VALUES (15,':eek:','icon_surprised.gif','Surprised');
INSERT INTO `torrent_smiles` VALUES (16,':x','icon_mad.gif','Mad');
INSERT INTO `torrent_smiles` VALUES (17,':-x','icon_mad.gif','Mad');
INSERT INTO `torrent_smiles` VALUES (18,':mad:','icon_mad.gif','Mad');
INSERT INTO `torrent_smiles` VALUES (19,'8O','icon_eek.gif','Shocked');
INSERT INTO `torrent_smiles` VALUES (20,'8-O','icon_eek.gif','Shocked');
INSERT INTO `torrent_smiles` VALUES (21,':shock:','icon_eek.gif','Shocked');
INSERT INTO `torrent_smiles` VALUES (22,':?','icon_confused.gif','Confused');
INSERT INTO `torrent_smiles` VALUES (23,':-?','icon_confused.gif','Confused');
INSERT INTO `torrent_smiles` VALUES (24,':???:','icon_confused.gif','Confused');
INSERT INTO `torrent_smiles` VALUES (25,'8)','icon_cool.gif','Cool');
INSERT INTO `torrent_smiles` VALUES (26,'8-)','icon_cool.gif','Cool');
INSERT INTO `torrent_smiles` VALUES (27,':cool:','icon_cool.gif','Cool');
INSERT INTO `torrent_smiles` VALUES (28,':lol:','icon_lol.gif','Laughing');
INSERT INTO `torrent_smiles` VALUES (29,':P','icon_razz.gif','Razz');
INSERT INTO `torrent_smiles` VALUES (30,':-P','icon_razz.gif','Razz');
INSERT INTO `torrent_smiles` VALUES (31,':razz:','icon_razz.gif','Razz');
INSERT INTO `torrent_smiles` VALUES (32,':oops:','icon_redface.gif','Embarassed');
INSERT INTO `torrent_smiles` VALUES (33,':cry:','icon_cry.gif','Crying or Very sad');
INSERT INTO `torrent_smiles` VALUES (34,':evil:','icon_evil.gif','Evil or Very Mad');
INSERT INTO `torrent_smiles` VALUES (35,':twisted:','icon_twisted.gif','Twisted Evil');
INSERT INTO `torrent_smiles` VALUES (36,':roll:','icon_rolleyes.gif','Rolling Eyes');
INSERT INTO `torrent_smiles` VALUES (37,':!:','icon_exclaim.gif','Exclamation');
INSERT INTO `torrent_smiles` VALUES (38,':?:','icon_question.gif','Question');
INSERT INTO `torrent_smiles` VALUES (39,':arrow:','icon_arrow.gif','Arrow');
INSERT INTO `torrent_smiles` VALUES (40,':|','icon_neutral.gif','Neutral');
INSERT INTO `torrent_smiles` VALUES (41,':-|','icon_neutral.gif','Neutral');
INSERT INTO `torrent_smiles` VALUES (42,':neutral:','icon_neutral.gif','Neutral');
INSERT INTO `torrent_smiles` VALUES (43,':bom:','bom.gif','bom');
INSERT INTO `torrent_smiles` VALUES (44,':pale:','icon_pale.gif','pale');
INSERT INTO `torrent_smiles` VALUES (45,':pirate:','icon_pirat.gif','pirate');
INSERT INTO `torrent_smiles` VALUES (46,':profileleft:','icon_profileleft.gif','profile_left');
INSERT INTO `torrent_smiles` VALUES (47,':profileright:','icon_profileright.gif','profile_right');
INSERT INTO `torrent_smiles` VALUES (48,':salute:','icon_salut.gif','salute');
INSERT INTO `torrent_smiles` VALUES (49,':santa:','icon_santa.gif','santa');
INSERT INTO `torrent_smiles` VALUES (50,':scratch:','icon_scratch.gif','scratch');
INSERT INTO `torrent_smiles` VALUES (51,':silent:','icon_silent.gif','silent');
INSERT INTO `torrent_smiles` VALUES (52,':thumbright:','icon_thumleft.gif','thumbright');
INSERT INTO `torrent_smiles` VALUES (53,':mumum:','mumum.gif','mumum');
INSERT INTO `torrent_smiles` VALUES (54,':angel4:','angel4.gif','angel4');
INSERT INTO `torrent_smiles` VALUES (55,':angry4:','angry4.gif','angry4');
INSERT INTO `torrent_smiles` VALUES (56,':banghead:','BangHead.gif','bandhead');
INSERT INTO `torrent_smiles` VALUES (57,':coffee:','coffee.gif','coffee');
INSERT INTO `torrent_smiles` VALUES (58,':crybaby:','crybaby2.gif','crybaby');
INSERT INTO `torrent_smiles` VALUES (59,':director:','director.gif','director');
INSERT INTO `torrent_smiles` VALUES (60,':evil1:','evil1.gif','evil1');
INSERT INTO `torrent_smiles` VALUES (61,':glasses1:','glasses1.gif','glasses1');
INSERT INTO `torrent_smiles` VALUES (62,':iconbiggrin:','icon_biggrin.gif','icon_biggrin');
INSERT INTO `torrent_smiles` VALUES (63,':icon_smile:','icon_smile.gif','icon_smile');
INSERT INTO `torrent_smiles` VALUES (64,':laughing6:','laughing7.gif','laughing6');
INSERT INTO `torrent_smiles` VALUES (65,':occasion2:','occasion5.gif','occasion2');
INSERT INTO `torrent_smiles` VALUES (66,':occasion5:','occasion14.gif','occasion5');
INSERT INTO `torrent_smiles` VALUES (67,':protest:','protest.gif','protest');
INSERT INTO `torrent_smiles` VALUES (68,':violent1:','violent1.gif','violent1');

--
-- Table structure for table `torrent_torrents`
--

CREATE TABLE `torrent_torrents` (
  `id` int(15) unsigned NOT NULL auto_increment,
  `info_hash` varchar(20) binary default NULL,
  `md5sum` varchar(32) default NULL,
  `name` varchar(255) NOT NULL default '',
  `filename` varchar(255) NOT NULL default '',
  `save_as` varchar(255) NOT NULL default '',
  `search_text` text NOT NULL,
  `descr` text NOT NULL,
  `torrent_descr` text NOT NULL,
  `plen` bigint(6) unsigned NOT NULL default '0',
  `size` bigint(20) unsigned NOT NULL default '0',
  `category` int(10) unsigned NOT NULL default '0',
  `type` enum('single','multi','link') NOT NULL default 'single',
  `numfiles` int(10) unsigned NOT NULL default '0',
  `added` datetime NOT NULL default '0000-00-00 00:00:00',
  `exeem` varchar(250) default NULL,
  `dht` enum('yes','no') NOT NULL default 'no',
  `backup_tracker` enum('true','false') NOT NULL default 'false',
  `views` int(10) unsigned NOT NULL default '0',
  `downloaded` int(10) unsigned NOT NULL default '0',
  `completed` int(10) unsigned NOT NULL default '0',
  `banned` enum('yes','no') NOT NULL default 'no',
  `password` varchar(255) default NULL,
  `private` enum('true','false') NOT NULL default 'false',
  `min_ratio` float unsigned NOT NULL default '0',
  `visible` enum('yes','no') NOT NULL default 'yes',
  `evidence` tinyint(1) NOT NULL default '0',
  `owner` int(10) unsigned NOT NULL default '0',
  `ownertype` tinyint(1) unsigned NOT NULL default '0',
  `uploader_host` varchar(100) NOT NULL default '',
  `numratings` int(10) unsigned NOT NULL default '0',
  `ratingsum` int(10) unsigned NOT NULL default '0',
  `seeders` int(10) unsigned NOT NULL default '0',
  `leechers` int(10) unsigned NOT NULL default '0',
  `tot_peer` int(11) unsigned NOT NULL default '0',
  `speed` int(10) unsigned NOT NULL default '0',
  `comments` int(10) unsigned NOT NULL default '0',
  `complaints` char(3) NOT NULL default '0,0',
  `tracker` varchar(250) default NULL,
  `tracker_list` text,
  `tracker_update` datetime NOT NULL default '0000-00-00 00:00:00',
  `last_action` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `info_hash` (`info_hash`),
  KEY `owner` (`owner`),
  KEY `visible` (`visible`),
  KEY `added` (`added`),
  KEY `seeders` (`seeders`),
  KEY `leechers` (`leechers`),
  KEY `tot_peer` (`tot_peer`),
  KEY `password` (`password`),
  KEY `tracker` (`tracker`),
  KEY `evidence` (`evidence`),
  KEY `rating` (`numratings`,`ratingsum`),
  KEY `numfiles` (`numfiles`),
  KEY `downloaded` (`downloaded`),
  KEY `category` (`category`),
  KEY `type` (`type`),
  FULLTEXT KEY `ft_search` (`search_text`),
  FULLTEXT KEY `filename` (`filename`),
  FULLTEXT KEY `torrent_descr` (`torrent_descr`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_torrents`
--

INSERT INTO `torrent_torrents` VALUES (5,'K@b∆SÃ7¬F¡xg¶s,B7’','e13c897fcfc1093e4a08f43897436178','Harbor at Night 2','harbor','harbor','harbor  harbor','<u>at2</u>','',32768,2329327,8,'multi',1,'2006-09-09 22:05:09','','yes','false',0,0,7,'no',NULL,'false',0,'yes',0,2,0,'ip-89-168-24-179.cust.homechoice.net',0,0,1,0,1,0,1,'0,0',NULL,NULL,'2006-09-09 22:05:09','2006-09-17 19:14:10');
INSERT INTO `torrent_torrents` VALUES (3,'ıdÚ•”’Â•HvÑ^≥.ﬁ©d¶’','ad20b9de2bc90a23160af8dfc2cc692d','Laugardalur','Laugardalur.JPG','Laugardalur','Laugardalur summer Laugardalur','summer','',32768,2568129,8,'single',1,'2006-09-09 21:31:16','','yes','false',0,0,1,'no',NULL,'false',0,'no',0,2,0,'ip-89-168-24-179.cust.homechoice.net',0,0,0,0,0,0,0,'0,0',NULL,NULL,'2006-09-09 21:31:16','2006-09-15 23:51:28');
INSERT INTO `torrent_torrents` VALUES (6,'x»óú≈ıÍ¬nRæU¯w–+Tß','0b31021ed579a39bb978410e8bd92fb7','field-trip-west-siberia','field-trip-west-siberia-avi','field-trip-west-siberia-avi','field-trip-west-siberia-avi siberia siberia','field-trip-west-siberia','',262144,477962195,3,'multi',4,'2006-09-10 07:32:14','','yes','false',0,0,1,'no',NULL,'false',0,'no',0,2,0,'ip-89-168-24-179.cust.homechoice.net',0,0,0,0,0,0,0,'0,0',NULL,NULL,'2006-09-10 07:32:14','2006-09-15 23:51:28');
INSERT INTO `torrent_torrents` VALUES (7,'ìt`tWëÔ˙©¸∑&ã≤p\rz','7d7034a622869d9fe7820d23b586adc7','star-wreck-in-the-pirkinning','star-wreck-in-the-pirkinning','star-wreck-in-the-pirkinning','star-wreck-in-the-pirkinning pirkinning pirkinning','star-wreck-in-the-pirkinning','',524288,601802620,3,'multi',4,'2006-09-10 07:33:42','','yes','false',1,0,1,'no',NULL,'false',0,'no',0,2,0,'ip-89-168-24-179.cust.homechoice.net',0,0,0,0,0,0,0,'0,0',NULL,NULL,'2006-09-10 07:33:42','2006-09-15 23:51:28');
INSERT INTO `torrent_torrents` VALUES (8,'Jö±ÈˇJ¬Œêü»€ÑÙÍm∂','d51d25524da32eea2e88361d702639f5','Blocks in Reykjavik','blocks','blocks','blocks  blocks','At night','',65536,2004451,8,'multi',1,'2006-09-10 21:22:49','','no','false',0,0,7,'no',NULL,'false',0,'yes',0,2,0,'ip-89-168-24-179.cust.homechoice.net',0,0,0,0,0,0,0,'0,0',NULL,NULL,'2006-09-10 21:22:49','2006-09-17 19:08:06');

--
-- Table structure for table `torrent_trackers`
--

CREATE TABLE `torrent_trackers` (
  `id` tinyint(5) unsigned NOT NULL auto_increment,
  `url` varchar(120) NOT NULL default '',
  `support` enum('selective','global','single') NOT NULL default 'selective',
  `status` enum('active','dead','blacklisted') NOT NULL default 'active',
  `updated` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `url` (`url`),
  KEY `update` (`updated`)
) TYPE=MyISAM;

--
-- Dumping data for table `torrent_trackers`
--


--
-- Table structure for table `torrent_users`
--

CREATE TABLE `torrent_users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(25) NOT NULL default '',
  `name` varchar(50) default NULL,
  `email` varchar(255) NOT NULL default '',
  `regdate` datetime NOT NULL default '0000-00-00 00:00:00',
  `password` varchar(40) NOT NULL default '',
  `theme` varchar(255) default NULL,
  `language` varchar(15) default NULL,
  `avatar` varchar(255) NOT NULL default 'blank.gif',
  `accept_mail` enum('yes','no') NOT NULL default 'no',
  `aim` varchar(255) default NULL,
  `icq` varchar(10) default NULL,
  `jabber` varchar(255) default NULL,
  `msn` varchar(255) default NULL,
  `skype` varchar(255) default NULL,
  `yahoo` varchar(255) default NULL,
  `level` enum('user','premium','moderator','admin') NOT NULL default 'user',
  `uploaded` bigint(32) unsigned NOT NULL default '0',
  `downloaded` bigint(32) unsigned NOT NULL default '0',
  `active` tinyint(1) default '0',
  `ban` int(1) unsigned NOT NULL default '0',
  `act_key` varchar(32) default NULL,
  `passkey` varchar(32) default NULL,
  `newpasswd` varchar(40) default NULL,
  `banreason` varchar(255) default NULL,
  `lastip` int(10) unsigned NOT NULL default '0',
  `lasthost` varchar(255) NOT NULL default '',
  `lastlogin` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `passkey` (`passkey`),
  KEY `lastip` (`lastip`),
  KEY `lasthost` (`lasthost`),
  KEY `date` (`regdate`)
) TYPE=MyISAM PACK_KEYS=0;

--
-- Dumping data for table `torrent_users`
--

INSERT INTO `torrent_users` VALUES (2,'robert','Robert Bjarnason','robofly@mail.com','2006-09-09 20:04:42','0de5f220010c9f29743a715d6076d08f',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,'robofly72@hotmail.com',NULL,NULL,'admin',1107894589,60604150,1,0,'OOKq2oto27vp64HaGuxm9dkJEMla1yvF','PYl6jXTKrBR92mnRH0OC2a1FVutLjHF0',NULL,NULL,1441437728,'ip-89-168-31-168.cust.homechoice.net','2006-09-17 14:17:31');
INSERT INTO `torrent_users` VALUES (3,'trebor',NULL,'robert.bjarnason@gmail.com','2006-09-09 22:21:32','0de5f220010c9f29743a715d6076d08f',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,0,1,0,'gZZPIOZAl8BHcclU2ujVLR35X1TTzOKV',NULL,NULL,NULL,1504188595,'ip-89-168-24-179.cust.homechoice.net','2006-09-09 22:37:14');
INSERT INTO `torrent_users` VALUES (4,'cs_trebor','trebor','2d5b1afa571a289002e43c374baa5bcd','2006-09-10 06:33:07','fddbd569f13d9e1834541b6a151c4bff',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,6987981,1,0,NULL,'dda50552cb5be501afe7f9ceb0126fc9',NULL,NULL,0,'','2006-09-10 06:33:07');
INSERT INTO `torrent_users` VALUES (5,'cs_robo','robo','c37ed6582275455621fbcde3b1d5db65','2006-09-10 07:51:52','08cb40d0b2d05c03f1009a98ffd21ca6',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,1034383934,1,0,NULL,'f446f68703d0b6612bb27851f529ab13',NULL,NULL,1504188595,'','2006-09-10 07:51:52');
INSERT INTO `torrent_users` VALUES (6,'cs_rbjarnason','rbjarnason','1e1a96d4766b22bdb9034d8b78fd8b5b','2006-09-10 15:57:34','c5c48094d83b5ebebca6b24e82a10ae3',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,0,1,0,NULL,'8fb2d6d24c8dea0754b5e3245dde0fba',NULL,NULL,0,'','2006-09-10 15:57:34');
INSERT INTO `torrent_users` VALUES (7,'cs_seeder.is.001','seeder.is.001','2217c7704131f62bcad9d82f46d653e0','2006-09-10 18:07:42','bf1ef08a49f89ef930a937592f7e6c21',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,0,1,0,NULL,'0a9360c4c5e1c2a708cb47f5047cad12',NULL,NULL,0,'','2006-09-10 18:07:42');
INSERT INTO `torrent_users` VALUES (8,'cs_seeder123','seeder123','d771a1d966f721f0523480cbd015a333','2006-09-10 22:00:35','f76ab7196658feb75d98aabd096a725a',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',2004451,4008902,1,0,NULL,'a1f80320758472f1f1a9bba71cdada52',NULL,NULL,1504188595,'','2006-09-10 22:00:35');
INSERT INTO `torrent_users` VALUES (9,'cs_trebor72','trebor72','df64e11af5ec8922b01bf950acfcd69a','2006-09-11 00:08:11','8aef6522329e282f75ac62197c5608f5',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,4658654,1,0,NULL,'605897076f67b4ca12d1ae646e017c82',NULL,NULL,1504188595,'','2006-09-11 00:08:11');
INSERT INTO `torrent_users` VALUES (10,'cs_trerob','trerob','f23de66e13c2165c8dba389a1b29d128','2006-09-11 02:28:28','e370e7e62a4dc8de3764ea5a6c681182',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',6016305,6016674,1,0,NULL,'80be02f5591ec77bb82909b718d02a32',NULL,NULL,1504191422,'','2006-09-11 02:28:28');
INSERT INTO `torrent_users` VALUES (11,'theory-x',NULL,'dave@decyphermedia.com','2006-09-11 09:10:16','aa0fa338ad941e77e6b41bcba7053c12',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,0,1,0,'1SreFjo2fnGhPMpSYLciDluTTTXQQi1H',NULL,NULL,NULL,0,'','0000-00-00 00:00:00');
INSERT INTO `torrent_users` VALUES (12,'cs_dparsons','dparsons','fe91e47f6abd5f848b95ce5fc7a3056a','2006-09-11 10:02:51','6ad8141791a43d7c1e907656dfd68e38',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',2004451,2004451,1,0,NULL,'c5847092e0229d64ac3700bc42a170d3',NULL,NULL,3643425461,'','2006-09-11 10:02:51');
INSERT INTO `torrent_users` VALUES (13,'cs_curiousb','curiousb','938067cba8440125f903303790383259','2006-09-11 10:52:10','00bda11c566db97c4aa9c6bf097ab829',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,0,1,0,NULL,'aa061dac524b81688708718c644a0baa',NULL,NULL,0,'','2006-09-11 10:52:10');
INSERT INTO `torrent_users` VALUES (14,'cs_admin','admin','b98660f7255270f952edc986f560ab70','2006-09-12 20:44:41','642927b734a9545d951892f2965ae2b0',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,2007034,1,0,NULL,'4ffb1038ede8f6ab4bd65073dfe20452',NULL,NULL,1472334822,'','2006-09-12 20:44:41');
INSERT INTO `torrent_users` VALUES (15,'cs_ooo123','ooo123','45844c80f44b622906112ebfabb16c60','2006-09-13 23:01:09','2d34f1a1b2d8090c8cb770e1c757fbc8',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',0,0,1,0,NULL,'c75fb899c07d9d5729a881fe70aaa9b9',NULL,NULL,0,'','2006-09-13 23:01:09');
INSERT INTO `torrent_users` VALUES (16,'cs_abc123','abc123','ebe9d32eff589d4e4843e4a7fce1901e','2006-09-13 23:15:09','cf7a737499b6762ac47dd1145bdccd13',NULL,NULL,'blank.gif','no',NULL,NULL,NULL,NULL,NULL,NULL,'user',6150742,4333778,1,0,NULL,'3b96e7126302b97645033309ff2dacb1',NULL,NULL,1504190376,'','2006-09-13 23:15:09');

