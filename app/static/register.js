    
var fname = document.getElementById("fname");
var lname = document.getElementById("lname");
var username = document.getElementById("username");
var password = document.getElementById("password");
var usertype = document.getElementById("usertype");
var emailarray[];

function register() {
    if (username.value == "") {
 
        alert("Enter Username");
 
    } else if (password.value  == "") {
 
        alert("Enter Password");
 
    } else if (fname.value == "" || lname.value == "") {
 
        alert("Enter Name");
 
    } else if (email.value == "") {
        
        alert("Enter Email");
    }
}

function saveEmail() {
        var email = document.getElementById("email").value;
        emaillarray.push(email);
        console.log(emailarray);
        document.getElementById("someemail").value=emailarray;
        console.log(document.getElementById("someemail").value);
  
}