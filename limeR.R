library(limer)
library(rstudioapi)
#library(readxl)
library(writexl)

fun_get_creds = function(){
  this_file = rstudioapi::getActiveDocumentContext()$path
  path = box::file()
  check_path = unlist(strsplit(this_file, split = "/"))
  check_path = paste0(check_path[1:length(check_path)-1], collapse="/")
  if (check_path != path){
    warning("There might be issues related to the path...", call. = TRUE, immediate. = FALSE, domain = NULL)
  }else{
    setwd(file.path(path, "data"))
    #allfiles = dir()
    return(read.delim("jne.txt", header = F, sep = "\n"))
  }
}

login = as.vector(fun_get_creds()) |> unlist()
print_xlsx = F

#change the next options (website, user, password)
options(lime_api = login[1])
options(lime_username = login[2])
options(lime_password = login[3])
rm(login)
#############################################################

# first get a session access key
get_session_key()

# list all surveys. A dataframe is returned
survey_df <- call_limer(method='list_surveys')
print(survey_df)
#    sid           surveyls_title startdate             expires active
#1  999999  XXXX               NA 2016-03-08 15:20:30      Y
#2  999998  XXXX               NA   <NA>      Y

#Read the data of the first survey (sid=999999) into a data.frame. 
#Notice that the default sLanguageCode = en, so maybe you have to 
#specify another language (here: All languages)
#data1<- get_responses(iSurveyID = 145654, sLanguageCode= '', sResponseType='short')
#data<- get_responses(iSurveyID = 173384, sLanguageCode= '', sResponseType='short')

responses = c()

for (i in 1:length(survey_df$sid)){
  print(paste("sid:", survey_df$sid[i]))
  
  get_responses = tryCatch({
    as.numeric(nrow(get_responses(iSurveyID = survey_df$sid[i], sLanguageCode= '', sResponseType='short')))
    },
  error = function(e) {
    cat("Error: ", conditionMessage(e), "\n")
    #substitute_df()
    get_responses = 0
    },
  warning = function(w) {
    cat("Warning: ", conditionMessage(w), "\n")
    get_responses = 0
    }
  )
  responses = append(responses, get_responses)
}

survey_df = cbind(survey_df[-2], responses = responses)


#<<<<<<<<<<<<<<<-> writexl <->>>>>>>>>>>>>>>#
if (print_xlsx == T){
  output_jne = "limer_jne.xlsx"
  write_xlsx(result_df, output_jne)
} else {
  print("No xlsx-output saved.")
}
#<<<<<<<<<<<<<<<->---------<->>>>>>>>>>>>>>>#


#stop("release session_key")
release_session_key()


