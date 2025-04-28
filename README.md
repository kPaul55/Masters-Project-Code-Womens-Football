# Masters-Project-Code-Womens-Football

### This project covers creating an expected pass model and performaing social network analysis on women's football data from the 2019 and 2023 Women's World Cups.
### R Studio was used to first extract the data from statsbomb API. Then python (jupyter notebooks using Anaconda) was used to performed data cleaning, modelling, and social network analysis.

### STEP 1
- Use the file data_extraction_project.R to reproduce the data extracted from Hudl Statsbomb.
- The output of this file is the womens_pass_data_new.xlsx file

### STEP 2
- The womens_pass_data_new.xlsx file was read into the Data_CleaningPrep.ipynb file and ran to clean/prep the data and perform exploratory analysis
- The output of the Data_CleaningPrep.ipynb file is the pass_data_modelling.xlsx file which is used in the model sections

### STEP 3
- Read the pass_data_modelling.xlsx file into the RF_XG_FinalModels.ipynb and GAT_FinalModel.ipynb to run the RF, XGBoost, and GAT models
- The RF_XG_FinalModels.ipynb output is the sna_data_v1.xlsx file

### STEP 4
- Read the sna_data_v1.xlsx file into the Social_Network_Analysis.ipynb file and run to produce the SNA results
