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
	
		var map, marker, markerLayer;
		
		function Calculate(){
			var sLatitudeRadians = 37.65535521290941 * (Math.PI / 180.0);
			var sLongitudeRadians = 127.0395472221932 * (Math.PI / 180.0);
			var eLatitudeRadians = 37.654590747417686 * (Math.PI / 180.0);
			var eLongitudeRadians = 127.04637076193177 * (Math.PI / 180.0);
			
			var dLongitude = eLongitudeRadians - sLongitudeRadians;
			var dLatitude = eLatitudeRadians - sLatitudeRadians;
			
			var result1 = Math.pow(Math.sin(dLatitude / 2.0), 2.0) + 
			   Math.cos(sLatitudeRadians) * Math.cos(eLatitudeRadians) * 
			   Math.pow(Math.sin(dLongitude / 2.0), 2.0);
			
			// Using 3956 as the number of miles around the earth
			var result2 = 3956.0 * 2.0 * 
			   Math.atan2(Math.sqrt(result1), Math.sqrt(1.0 - result1));
			
			console.log(result2);
			
			return result2;
		}
	
		function initTmap(){
			
			map = new Tmap.Map({div:'map_div', // map을 표시해줄 div
								width:'100%',  // map의 width 설정
								height:'850px' // map의 height 설정
								}); 
			
			map.setCenter(new Tmap.LonLat("127.04090314262496", "37.65350370915024").transform("EPSG:4326", "EPSG:3857"), 16);
			
			markerLayer = new Tmap.Layer.Markers(); //마커 레이어 생성
			map.addLayer(markerLayer); //map에 마커 레이어 추가
			
			vectorLayer = new Tmap.Layer.Vector(); // 백터 레이어 생성
			map.addLayers([vectorLayer]); // 지도에 백터 레이어 추가
			
			//map.events.register("click", map, onClick);
		}
		
		$(function() {
			Calculate();
		});
		
	</script>
</head>
<body>
	<div id='map_div'></div>
</body>
</html>