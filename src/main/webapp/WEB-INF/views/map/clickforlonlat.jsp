<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Insert title here</title>
	<script src="https://api2.sktelecom.com/tmap/js?version=1&format=javascript&appKey=e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script type="text/javascript">
		var map;
		
		function initTmap() {
			map = new Tmap.Map({div:'map_div', // map을 표시해줄 div
								width:'100%',  // map의 width 설정
								height:'850px' // map의 height 설정
								});

			map.setCenter(new Tmap.LonLat("127.04597379499731", "37.65369036685572").transform("EPSG:4326", "EPSG:3857"), 17);
			
			map.events.register("click", map, onClick);
		}
		
		function onClick(e){
			
			var clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326");
			
			var result = clonlat.lon + " " + clonlat.lat;
			
			console.log(result);
			
			var resultDiv = document.getElementById("result");
			resultDiv.innerHTML = result;
		}
		
		$(function(){
			initTmap();
		});
	
	</script>
</head>
<body>
	<div id='map_div'></div>
	<p id='result'></p>
</body>
</html>