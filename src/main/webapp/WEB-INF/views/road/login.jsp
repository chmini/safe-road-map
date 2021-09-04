<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
	<style type="text/css">
	    body{
	        background-color: black;
	    }
	
	    #container{
	        margin: 0 auto;
	        text-align: center;
	    }
	
	    .Content{
	        position: absolute;
	        width: 500px;
	        height: 300px;
	        left: 50%;
	        top: 50%;
	        margin-left: -250px;
	        margin-top: -150px;
	    }
	
	    .Title{
	        color: white;
	    }
	    .Title > strong{
	        color : #1AAB8A;
	    }
	
	    .Content > *{
	        font-size: 40px;
	    }
	
	    .Login input{
	        height: 30px;
	        width: 300px;
	        outline: none;
	        color: #fff;
	        font-size: 15px;
	        border-top-width:0;
	        border-left-width:0;
	        border-right-width:0;
	        border-bottom-width:1;
	        background-color:black;
	    }
	
	    .Login input::placeholder{
	        color: white;
	    }
	
	    .LoginBtn{
	        border:none;
	        height:50px;
	        color:#fff;
	        outline:none;
	        width: 300px;
	        font-size: 30px;
	        cursor: pointer;
	        position: relative;
	        background:#1AAB8A;
	        margin: 20px 0 2px 0;
	        transition:800ms ease all;
	    }
	
	    .LoginBtn:hover{
	        color:#1AAB8A;
	        background:#fff;
	    }
	
	    .LoginBtn::before, .LoginBtn::after{
	        top:0;
	        right:0;
	        width:0;
	        content:'';
	        height:2px;
	        position:absolute;
	        background: #1AAB8A;
	        transition:400ms ease all;
	    }
	
	    .LoginBtn::after{
	        left: 0;
	        bottom: 0;
	        top: inherit;
	        right: inherit;
	    }
	
	    .LoginBtn:hover::before, .LoginBtn:hover::after{
	        width:100%;
	        transition:800ms ease all;
	    }
	    
	    .Join a{
	        float: right;
	        width: 260px;
	        outline: none; 
	        color: #fff;
	        font-size: 15px;
	        text-decoration: none;
	    }
	    .Join > a:hover, a:active{
	        color: #1AAB8A;
	        text-decoration: none;
	    }
	</style>
</head>
<body>
   <div id="container">
        <div class="Content">
            <div>
                <div class="Title"><strong>당신의 안전</strong>을 위하여</div>
                <div class="Login">
                    <form action="#">
                        <input placeholder="아이디"><br>
                        <input type="password" placeholder="비밀번호"><br>
                        <button type="submit" class="LoginBtn">로그인</button>
                    </form>
                </div>
                <div class="Join">
                    <a href="#">회원가입</a>
                </div>
            </div>
        </div>
   </div>
</body>
</html>