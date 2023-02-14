import sqlite3
import json
import flask
from flask_restful import Resource, Api
from flask_api import status
from flask import (Flask, render_template, Markup, request, make_response, jsonify)
import requests
import random
import string

"""
INITIALIZING
"""

conn = sqlite3.connect("Project2122.db", check_same_thread=False)

api_address = "http://127.0.0.1:8080"

# Create our app
app = flask.Flask(__name__)
# Create an API for our app
api = Api(app)   

"""
COMMUNICATION
"""

# Check if username and password match, if so -> return session key and grant login
def check_login(username, password):
    #Ideally this password should be hashed
    url = api_address + "/show/logindata/" + username + "," + password
    data = requests.get(url)
    data_json = data.json()
    #Json is empty -> user doesn't exist in DB
    if data_json == False:
        return (False, -1)
    else: 
        #Username and password don't match
        if data_json['Username'] == username and data_json['Password'] == password:
            session_key = generate_session_key()
            return (True, session_key)
        else: 
            return (False, -1)
    
# Get Name of current user -> only used while logging in because data is not yet added to the active user table
def get_name_and_roll(username):
    url = api_address + "/show/nameandroll/" + username
    data = requests.get(url)
    return data.json()

# Get Name, Email and Roll of current user via token(SessionKey) 
def get_active_user_data(token):
    url = api_address + "/show/activeuserdata/" + token
    data = requests.get(url)
    return data.json()
    
# Get Present Students for a Class from the database
def get_present_students(class_name):
    url = api_address + "/show/presence/class/" + class_name
    data = requests.get(url)
    return data.json()

# Get AccountID for given username
def get_accountID(username):
    url = api_address + "/show/accountID/" + username
    data = requests.get(url)
    return data.json()

# Get Name and Username for given accountID
def get_name_and_username(accountID):
    url = api_address + "/show/nameandusername/" + accountID
    data = requests.get(url)
    return data.json()

# Get CourseID for given course name
def get_courseID(course_name):
    url = api_address + "/show/courseID/" + course_name
    data = requests.get(url)
    return data.json()

#Get CourseID for given class name
def get_courseID_via_class(class_name):
    url = api_address + "/show/courseID/class/" + class_name
    data = requests.get(url)
    return data.json()

# Get all users that are not present for a given course
def get_nonpresent_students(present_data_json):
    ##Get all the registrated students for the course
    #Get the corresponding courseID via the class name
    class_name = present_data_json['Class Name'][0]
    url_courseID = api_address + "/show/courseID/class/" + str(class_name)
    courseID_data = requests.get(url_courseID)
    courseID_data_json = courseID_data.json()
    courseID = courseID_data_json['Course ID']
    #Get all the registrated accountIDs via the courseID
    url_accountID = api_address + "/show/accountID/courseID/" + str(courseID)
    data_accountID = requests.get(url_accountID)
    data_accountID_json = data_accountID.json()
    registrated_accountIDs = []
    for key,value in data_accountID_json.items():
        if key == 'Account ID':
            registrated_accountIDs.append(value)            
    ##Get all the accountID's of the current present students
    present_accountIDs = []
    present_usernames = []
    #Get usernames
    for key, value in present_data_json.items():
        if key == 'Email':
            present_usernames.append(value)
    #Convert username to accountID
    for item in range(len(present_usernames)):
        data = get_accountID(present_usernames[0][item])
        accountID = data['Account ID']
        present_accountIDs.append(accountID)        
    ##Check which students were not present and return them
    absent_accountIDs = []
    #Get the accountID of the absent students
    for i in range(len(registrated_accountIDs[0])):
        if registrated_accountIDs[0][i] not in present_accountIDs:
            absent_accountIDs.append(registrated_accountIDs[0][i])
    #Get the Name and Username of absent students
    absent_students = []
    for i in range(len(absent_accountIDs)):
        accountID = absent_accountIDs[i]
        url_name_username = api_address + "/show/nameandusernameandroll/" + str(accountID)
        data_name_username = requests.get(url_name_username)
        data_name_username_json = data_name_username.json()
        temp_list = []
        #Only add to the list if the accountID is a student
        if data_name_username_json['RollID'] != 2: 
            temp_list.append(data_name_username_json['Name'])
            temp_list.append(data_name_username_json['Username'])
            absent_students.append(temp_list)
    return absent_students
    
# Check Duplicate Presence Code, Returns False if there are NO duplicates
def check_duplicate_code(unique_code):
    url = api_address + "/show/duplicatecodes/" + unique_code
    data = requests.get(url)
    data_json = data.json()
    #Json is empty -> No duplicates
    if data_json['Presence Code'] == False: 
        return False
    else:
        return True
    
# Check if Course exists in the database
def check_course_indb(course_name):
    url = api_address + "/show/course/" + course_name
    data = requests.get(url)  
    data_json = data.json()      
    #Json is empty -> Doesn't exist
    if data_json['Course Name'] == False:
        return False
    else:
        return True

#Check if the Class exists in the database
def check_class_indb(class_name):
    url = api_address + "/show/class/" + class_name
    data = requests.get(url)
    data_json = data.json()
    #Json is empty -> Doesn't exit
    if data_json['Class Name'] == False:
        return False
    else:
        return True

#Check if username exists in the database
def check_username_indb(username):
    url = api_address + "/show/user/" + username
    data = requests.get(url)
    data_json = data.json()
    #Json is empty -> Doesn't exist
    if data_json['Username'] == False:
        return False
    else:
        return True

#Check if user is registrated in the course associated for a presence code
def check_registration_indb(presence_code, current_accountID):
    #Get the courseID via the presence Code
    url_courseID = api_address + "/show/courseID/presence/" + presence_code
    data_courseID = requests.get(url_courseID)
    data_courseID_json = data_courseID.json()
    courseID = data_courseID_json['Course ID']
    #Get all the accountIDs via the courseID
    url_accountID = api_address + "/show/accountID/courseID/" + str(courseID)
    data_accountID = requests.get(url_accountID)
    data_accountID_json = data_accountID.json()
    accountIDs = []
    for key,value in data_accountID_json.items():
        if key == 'Account ID':
            accountIDs.append(value)
    check = False
    for item in range(len(accountIDs)):
        if current_accountID == accountIDs[0][item]:
            check = True
    return check  

# Add Active user to the database -> seperate Active User Table
def add_session_db(accountID, username, name, roll, token):
    url = '{}/add/activeuser/{},{},{},{},{}'.format(api_address, accountID, username, name, roll, token)
    requests.get(url)

# Add Presence Code and AccountID to the database Presence Table
def add_presence_account_db(presence_code, account_ID):
    url = '{}/add/presence/{},{}'.format(api_address, presence_code, account_ID)
    requests.get(url)
    
# Add Course and Class to the Database
def add_course_class_db(course_name, class_name, account_ID, presence_code):
    #First Check if the Course already exists
    check = check_course_indb(course_name)
    #List is empty -> Course doesn't exist -> Add Course to database, RollID Required     
    if check == False:
        url_check = '{}/add/course/{},{}'.format(api_address, course_name, account_ID)
        requests.get(url_check)
    #Get the course_ID   
    courseID_data = get_courseID(course_name)
    courseID = courseID_data['Course ID']
    #Add Class to the matching Course
    url_addClass = '{}/add/class/{},{},{}'.format(api_address, class_name, courseID, presence_code)
    requests.get(url_addClass)

# Add User from Database to a specific Course in the database -> Assign Course
def add_course_db(courseID, course_name, username):
    # Get the AccountID
    accountID_data = get_accountID(username)
    accountID = accountID_data['Account ID']
    # Add the course and the accountID to the database
    url_add = '{}/add/assigncourse/{},{},{}'.format(api_address, courseID, course_name, accountID)
    requests.get(url_add)

# Delete Active Users on startup
def delete_active_user(username):
    url = api_address + "/delete/activeusers/" + username
    requests.get(url)
    
    

"""
CLASSES
"""

# Show the user login data from the databse
class ShowLoginData(Resource):
    def get(self, username, password):
        username_password = []
        q = "SELECT Email, Password FROM Account WHERE Email = ? AND Password = ?"
        data = conn.execute(q,(username, password)).fetchall()
        for row in data:
            for item in row:
                username_password.append(item)                
        if not username_password:
            return False
        else:
            return {"Username": username_password[0], "Password": username_password[1]}
 
# Show current name and roll while logging in
class ShowNameAndRoll(Resource):
    def get(self, username):
        q = "SELECT Account.Name, Roll.RollName FROM Account INNER JOIN Roll on Account.RollID = Roll.RollID  WHERE Email = ?"
        data = conn.execute(q,(username, )).fetchall()
        i = 0
        for row in data:
            for item in row:
                if i == 0: name = item
                if i == 1: roll = item
                i = i + 1     
        return {"Name": name, "Roll": roll}
    
# Show Name, Email and Roll of current user via token
class ShowActiveUserData(Resource):
    def get(self, token):
        q = "SELECT AccountID, Email, Name, RollName FROM ActiveUser WHERE SessionKey like ?"
        data = conn.execute(q, (token, )).fetchall()
        active_user_data = []
        for row in data:
            for item in row:
                active_user_data.append(item)
        return {"AccountID": active_user_data[0], "Email": active_user_data[1], "Name": active_user_data[2], "Roll": active_user_data[3]}

# Show all students that were present during give classname  
class ShowPresencePerClass(Resource):
    def get(self, class_name):
        q = "SELECT Class.ClassName, Account.Name, Account.Email FROM Presence  INNER JOIN Account ON Presence.AccountID = Account.AccountID INNER JOIN Class ON Class.PresenceCode = Presence.CodeID WHERE ClassName = ?;"
        data = conn.execute(q, (class_name, )).fetchall()
        presence_list = []
        for row in data:
            presence_list.append(row)           
        result = {
                        "Class Name": [],
                        "Name": [],
                        "Email": [],
                        }
        for i in range(len(presence_list)):
            result["Class Name"].append(presence_list[i][0])
            result["Name"].append(presence_list[i][1])
            result["Email"].append(presence_list[i][2])                
        return result
   
# Show presence codes with unique code
class ShowDuplicateCodes(Resource):
    def get(self, unique_code):
        q = "SELECT PresenceCode FROM Class WHERE PresenceCode = ?"
        data = conn.execute(q, (unique_code, )).fetchall()
        presence_code = []
        for row in data:
            for item in row:
                presence_code.append(row)
        if not presence_code:
            result = False
            return {"Presence Code": result}
        else:           
            return {"Presence Code": presence_code[0]}


# Show courses with given course name
class ShowCourse(Resource):
    def get(self, course_name):
        q = "SELECT CourseName FROM Course WHERE CourseName = ?"
        data = conn.execute(q, (course_name, )).fetchall()
        course_name = []
        for row in data:
            for item in row:
                course_name.append(item)
        if not course_name:
            result = False
            return {"Course Name": result}
        else:
            return {"Course Name": course_name[0]}       
 
# Show class for given class name
class ShowClass(Resource):
    def get(self, class_name):
        q = "SELECT ClassName FROM Class WHERE ClassName = ?"
        data = conn.execute(q, (class_name, )).fetchall()
        class_name = []
        for row in data:
            for item in row:
                class_name.append(item)
        if not class_name:
            result = False
            return {"Class Name": result}
        else:
            return {"Class Name": class_name[0]}

#Show user for given username
class ShowUser(Resource):
    def get(self, username):
        q = "SELECT Email FROM Account WHERE Email = ?"
        data = conn.execute(q, (username, )).fetchall()
        username = []
        for row in data:
            for item in row:
                username.append(item)
        if not username:
            result = False
            return {"Username": result}
        else:
            return {"Username": username[0]}

#Show name and username for given accountID
class ShowNameAndUsernameAndRoll(Resource):
    def get(self, accountID):
        q = "SELECT Name, Email, RollID FROM Account WHERE AccountID = ?"
        data = conn.execute(q, (accountID, )).fetchall()
        name_username_roll = []
        for row in data:
            for item in data:
                name_username_roll.append(row)
        return {"Name": name_username_roll[0][0], "Username": name_username_roll[0][1], "RollID": name_username_roll[0][2]}

# Show courseID for given course name
class ShowCourseID(Resource):
    def get(self, course_name):
        q = "SELECT CourseID FROM Course WHERE CourseName = ?"
        data = conn.execute(q, (course_name, )).fetchall()
        courseID = []
        for item in data:
            for row in item:
                courseID.append(row)
        if not courseID:
            result = False
            return {"Course Name": result}
        else:
            return {"Course ID": courseID[0]}

# Show CourseID for given class name
class ShowCourseIDViaClassName(Resource):
    def get(self, class_name):
        q = "SELECT CourseID FROM Class WHERE ClassName = ?"
        data = conn.execute(q, (class_name, )).fetchall()
        courseID = []
        for item in data:
            for row in item:
                courseID.append(row)
        return {"Course ID": courseID[0]}
    
# Show accountID for given username
class ShowAccountID(Resource):
    def get(self, username):
        q = "SELECT AccountID FROM Account WHERE Email = ?"
        data = conn.execute(q, (username, )).fetchall()
        accountID = []
        for item in data:
            for row in item:
                accountID.append(row)
        return {"Account ID": accountID[0]}

# Show all AccountID's for a given courseID
class ShowAccountIDsViaCourseID(Resource):
    def get(self, courseID):
        q = "SELECT AccountID FROM Course WHERE CourseID = ?"
        data = conn.execute(q, (courseID, )).fetchall()
        accountIDs = []
        for item in data:
            for row in item:
                accountIDs.append((row))
        result = {"Account ID": []}
        for i in range(len(accountIDs)):
            result['Account ID'].append(accountIDs[i])
        return result        
        
# Show courseID for given presence_code
class ShowCourseIDViaPresenceCode(Resource):
    def get(self, presence_code):
        q = "SELECT CourseID FROM Class WHERE PresenceCode = ?"
        data = conn.execute(q, (presence_code, )).fetchall()
        courseID = []
        for item in data:
            for row in item:
                courseID.append(row)
        return {"Course ID": courseID[0]}

# Add active user data to the database
class AddActiveUser(Resource):
    def get(self, accountID, username, name, roll, token):
        q = """INSERT OR REPLACE INTO "main"."ActiveUser"("AccountID","Email", "Name", "RollName", "SessionKey") VALUES (?, ?, ?, ?, ?);"""
        conn.execute(q,(accountID, username, name, roll, token))
        conn.commit()

# Add active user to the presence table
class AddToPresence(Resource):
    def get(self, presence_code, account_ID):
        q = """INSERT OR IGNORE INTO "main"."Presence" ("CodeID", "AccountID") VALUES (?, ?);"""
        conn.execute(q, (presence_code, account_ID))
        conn.commit()
        
# Add given course and accountID to the database
class AddCourse(Resource):
    def get(self, course_name, account_ID):
        q = """INSERT OR IGNORE INTO "main"."Course"(CourseName", "AccountID") VALUES (?, ?);"""
        conn.execute(q,(course_name, account_ID))
        conn.commit()
        
# Add Class to the matching Course
class AddClass(Resource):
    def get(self, class_name, courseID, presence_code):
        q = """INSERT OR IGNORE INTO "main"."Class" ("ClassName", "CourseID", "PresenceCode") VALUES (?, ?, ?);"""
        conn.execute(q, (class_name, courseID, presence_code))
        conn.commit()

# Add course name and accountID to the database -> assign course
class AddAssignCourse(Resource):
    def get(self, courseID, course_name, accountID):
        q = """INSERT OR IGNORE INTO "main"."Course"("CourseID", "CourseName", "AccountID") VALUES (?, ?, ?);"""
        conn.execute(q, (courseID, course_name, accountID))
        conn.commit()

# Delete active users
class DeleteActiveUsers(Resource):
    def get(self, username):
        q = "DELETE FROM ActiveUser WHERE Email = ?"
        conn.execute(q, (username, ))
        conn.commit()

##---Resources---##
api.add_resource(ShowLoginData, "/show/logindata/<string:username>,<string:password>")
api.add_resource(ShowNameAndRoll, "/show/nameandroll/<string:username>")
api.add_resource(ShowActiveUserData, "/show/activeuserdata/<string:token>")
api.add_resource(ShowPresencePerClass, "/show/presence/class/<string:class_name>")
api.add_resource(ShowDuplicateCodes, "/show/duplicatecodes/<string:unique_code>")
api.add_resource(ShowCourse, "/show/course/<string:course_name>")
api.add_resource(ShowClass, "/show/class/<string:class_name>")
api.add_resource(ShowUser, "/show/user/<string:username>")
api.add_resource(ShowNameAndUsernameAndRoll, "/show/nameandusernameandroll/<string:accountID>")
api.add_resource(ShowCourseID, "/show/courseID/<string:course_name>")
api.add_resource(ShowCourseIDViaClassName, "/show/courseID/class/<string:class_name>")
api.add_resource(ShowAccountID, "/show/accountID/<string:username>")
api.add_resource(ShowAccountIDsViaCourseID, "/show/accountID/courseID/<string:courseID>")
api.add_resource(ShowCourseIDViaPresenceCode, "/show/courseID/presence/<string:presence_code>")
api.add_resource(AddActiveUser, "/add/activeuser/<string:accountID>,<string:username>,<string:name>,<string:roll>,<string:token>")
api.add_resource(AddToPresence, "/add/presence/<string:presence_code>,<string:account_ID>")
api.add_resource(AddCourse, "/add/course/<string:course_name>,<string:account_ID>")
api.add_resource(AddClass, "/add/class/<string:class_name>,<string:courseID>,<string:presence_code>")
api.add_resource(AddAssignCourse, "/add/assigncourse/<string:courseID>,<string:course_name>,<string:accountID>")
api.add_resource(DeleteActiveUsers, "/delete/activeusers/<string:username>")

"""
FUNCTIONS
"""

# Generate Random Presence Code
def generate_class_code():
    code_list = random.choices(string.ascii_uppercase + string.digits, k=5)
    code = ""
    for item in code_list:
        code += item
    return code

# Generate Random Session Key
def generate_session_key():
    key_list = random.choices(string.ascii_lowercase + string.digits, k=5)
    key = ""
    for item in key_list:
        key += item
    return key

#Convert the json data to a list
def filter_data(json_data):
    result = []
    temp_class = []
    temp_name = []
    temp_email = []  
    for key in json_data.keys():
        for value in json_data[key]:
            if key == "Class Name":
                temp_class.append(value)
            if key == "Name":
                temp_name.append(value)
            if key == "Email":
                temp_email.append(value)    
    temp = []
    for i in range(len(temp_class)):
        temp = []
        temp.append(temp_class[i])
        temp.append(temp_name[i])   
        temp.append(temp_email[i])
        result.append(temp)            
    return result

"""
ROUTING
"""
##Log In Page
#Show log in page
@app.route("/login")
def login_page():
    return render_template("login.html")

##Log In Attempt Page
#Checks if login was succes 
@app.route("/login_attempt", methods=['POST'])
def login():
     #Get data from form
     username = request.form.get('username')
     password = request.form.get('password')
     
     #Check if login was succesfull
     (succes, token) = check_login(username, password)
     if succes == True:
         #Succesfull log in
         data = get_name_and_roll(username)
         name = data['Name']
         roll = data['Roll']
         #Delete previous user with same login
         delete_active_user(username)
         #Go to homepage
         response = make_response(render_template("homepage.html", contents = "Welcome " + name))
         response.set_cookie("auth_token", token)
         #Add active user into database -> specific active user table
         accountID_data = get_accountID(username)
         accountID = accountID_data['Account ID']
         add_session_db(accountID, username, name, roll, token)
     else:
         #Failed to log in
         response = make_response(render_template("login_error_page.html", title="Failed to log in", contents="Failed to log in"))
     return response
    
     
@app.route("/login_attempt", methods=["GET"])
def login_attempt_get():
    return render_template("login.html")


@app.route("/homepage")
def homepage():
    #See if session key from current user is still in the database
    token = request.cookies.get("auth_token")
    active_user_data = get_active_user_data(token)
    
    #See if user is stilled logged in -> token contains SessionKey => if so, continue 
    if token:
        #Display welcome message
        name = active_user_data['Name']
        return render_template("homepage.html", contents = "Welcome " + name)
    #User not logged in anymore -> show error page    
    else:
        return render_template("login_error_page.html", contents = "Not Logged In: Return to Log In Page")
   
     
@app.route("/create_class", methods=['POST', 'GET'])
def create_class():
    #See if session key from current user is still in the database
    token = request.cookies.get("auth_token")
    active_user_data = get_active_user_data(token)
    
    #See if user is stilled logged in -> token contains SessionKey => if so, continue 
    if token:
        #Check if the current user is a teacher or admin
        if active_user_data['Roll'] == 'Teacher' or active_user_data['Roll'] == 'Admin':
            #Check if button is pressed, if so, execute all functions
            if request.form.get('create_class_button') == 'pressed':
                #Get the data from the form and generate presence code
                course_name = request.form.get('course_name')
                class_name =  request.form.get('class_name')
                class_name = course_name + " " + class_name
                presence_code = generate_class_code() 
        
                #Make Sure that the code not already exists in the database
                duplicate = check_duplicate_code(presence_code)
                
                #No duplicates -> Add Course and Class to database 
                if duplicate == False:
                    #Ideally -> Create course if it doesn't exist already
                    accountID = active_user_data['AccountID']
                    add_course_class_db(course_name, class_name, accountID, presence_code)
                    #Return Unique Code
                    return render_template("create_class.html", contents = presence_code)
                #There is a duplicate
                else:                   
                    return render_template("create_class.html", contents = "This Class Already Exists")
            #Button is not yet pressed
            else:
                return render_template("create_class.html")
        #User is not an admin or teacher -> return not authorized status
        else:
            return render_template("wrong_roll_error_page.html", contents = "Not Authorized to Create a Class") 
    #User not logged in anymore -> show error page    
    else:
        return render_template("login_error_page.html", contents = "Not Logged In: Return to Log In Page")


@app.route("/register_presence", methods=['POST', 'GET'])
def register_presence():
    #See if session key from current user is still in the database
    token = request.cookies.get("auth_token")
    active_user_data = get_active_user_data(token)
    
    #See if user is stilled logged in -> token contains SessionKey => if so, continue 
    if token:
        #Check if button is pressed, if so, execute all functions
        if request.form.get('register_presence_button') == 'pressed':
            #Get the data from the form
            presence_code = request.form.get('presence_code')
            accountID = active_user_data['AccountID']
            #Check if the current user is registrated in the course, if so -> continue
            if check_registration_indb(presence_code, accountID) == True:
                #Get presence code and user data and insert it in the database
                #Ideally -> see if the user is already registrated for that presence code
                add_presence_account_db(presence_code, accountID)
                return render_template("register_presence.html", contents = "Presence Registrated!")
            #User is not registrated in the linked course
            else:
                return render_template("register_presence.html", contents = "Not Registrated in the Course!")
        #Button is not yet pressed
        else:
            return render_template("register_presence.html")
    #User not logged in anymore -> show error page    
    else:
        return render_template("login_error_page.html", contents = "Not Logged In: Return to Log In Page")
    

@app.route("/see_presence", methods=['POST', 'GET'])
def see_presence():
    #See if session key from current user is still in the database
    token = request.cookies.get("auth_token")
    active_user_data = get_active_user_data(token)
    
    #See if user is stilled logged in -> token contains SessionKey => if so, continue 
    if token:
        #Check if the current user is a teacher or admin
        if active_user_data['Roll'] == 'Teacher' or active_user_data['Roll'] == 'Admin':
            #Check if button is pressed, if so, execute functions
            if request.form.get('see_presence_button') == 'class':
                #Get Class Name from the form
                class_name = request.form.get('class_name')
                #Check if Class Name is in the database
                if check_class_indb(class_name) == True:
                    ##Get the data from the API
                    #Present Students
                    present_headings = ("Class Name", "Name", "Email")
                    present_json_data = get_present_students(class_name)
                    present_data = filter_data(present_json_data)
                    #Nonpresent Students
                    non_present_headings = ["Name", "Email"]
                    non_present_data = get_nonpresent_students(present_json_data)
                    return render_template("see_presence.html", present_headings=present_headings, present_data=present_data, non_present_headings=non_present_headings, non_present_data=non_present_data)                
                else:
                    return render_template("see_presence.html", contents = "Class not in database") 
            else:
                return render_template("see_presence.html")
        else:
            return render_template("wrong_roll_error_page.html", contents = "Not Authorized to See Presence")
    #User not logged in anymore -> show error page    
    else:
        return render_template("login_error_page.html", contents = "Not Logged In: Return to Log In Page")

@app.route("/assign_course", methods=['POST', 'GET'])
def assign_course():
    #See if session key from current user is still in the database
    token = request.cookies.get("auth_token")
    active_user_data = get_active_user_data(token)
    
    #See if user is stilled logged in -> token contains SessionKey => if so, continue 
    if token:
        #Check if the current user is an admin
        if active_user_data['Roll'] == 'Admin':
            #Check if button is pressed, if so, execute all functions
            if request.form.get('assign_course_button') == 'pressed':
                username = request.form.get('username') #Name of the given user, not the active user!
                course_name = request.form.get('course_name')
                #Check if the given username AND given course exists in the DB
                if check_course_indb(course_name) == True and check_username_indb(username) == True:
                    #Assign the user to the course 
                    #Ideally -> check if the user is already registrated for that course
                    courseID_data = get_courseID(course_name)
                    courseID = courseID_data['Course ID']
                    add_course_db(courseID, course_name, username)
                    return render_template("assign_course.html", contents = "User Assigned to " + course_name)
                else:
                    #Course doesn't exist in the database -> return error message
                    return render_template("assign_course.html", contents = "Username or Course don't exist")
            #Button is not yet pressed
            else:
                return render_template('assign_course.html')              
        #User is not an admin or teacher -> return not authorized status
        else:
            return render_template("wrong_roll_error_page.html", contents = "Not Authorized to Assign a Course")
    #User not logged in anymore -> show error page    
    else:
        return render_template("login_error_page.html", contents = "Not Logged In: Return to Log In Page")


"""
START APP
"""
if __name__ == '__main__':
    app.run(port=8080)
