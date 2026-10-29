# Group5stat392
Files titled ‘deidScholarship.year’ are the raw scholarship files by year that we were given

We then decided to make a master scholarship CSV to make data cleaning easier, even though some applications were different.

This is reflected in the file ‘masterScholarship.csv’

We then compiled a list of all of the winners and nonwinners based on the ‘amount awarded’ column in the spreadsheet which reflects how much students win. This is saved in a csv as ‘$WonMasterScholarship’

We then decided to start to clean the data set with two goals in mind. 

First our goal was to reach a data set with just one row per applicant to avoid double counting, and only include applicants with complete applications. We ran into a lot of issues and had to find creative ways to do so. Progress files include ‘CompleteApps.MasterScholarships’ which is just those complete applications of which there are about 20 thousand, then we ranked application status’ so students would only be represented as their furthest stage of application ie. a student winning only is only represented as winning money for the scholarships they got money from and not their rejected applications. This is represented as ‘MasterCompleteRanked’. 

From there, we joined all applicants with the same name to get 3,600 applicants who completed applications at their furthest stage. This end file is represented as ‘OneRowPerApplicant’. 

Our second major goal of cleaning was filling in blank towns for the years 22-24, as they are empty, using town specific scholarship information. We assigned strength values to scholarships based on how specific they were (ie. town specific = 1, HS specific from diff towns = 2, Multi town specific = 3…) in order to back log these towns for ones which are empty. First we made sure we could get a tally of all winners and losers by town represented by ‘LocationTallyPreSchol’ which shows us $ amount awarded per town without the towns from 22-24. Since we previously combined students to one row, we then assigned strength values to their scholarships similar to the process done for towns. Using this, we added external scholarship data, and then assigned towns to those strength based applicants as possible. The end result is represented in ‘LocationTallyPostSchol’.

In order to make a visual comparison and further some research based on our original question, we split Worcester County into the Worcester region, North east from worcester (Northeast), North west from Worcester and etc. for all regions. 
