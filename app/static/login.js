function login() {
 
    var username = document.getElementById("username");
    var pass = document.getElementById("password");
 
    if (username.value == "") {
 
        alert("Enter Username");
 
    } else if (pass.value  == "") {
 
        alert("Enter Password");
 
    } else {
 
        alert("Input Incorrect")
 
    }
}
