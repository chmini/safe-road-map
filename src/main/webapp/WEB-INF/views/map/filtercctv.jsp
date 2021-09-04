<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Insert title here</title>
	
	<script src="https://api2.sktelecom.com/tmap/js?version=1&format=javascript&appKey=e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script type="text/javascript">									
		var map, marker, markerLayer, vectorLayer;
		
		var count = 0;
		var positions = new Array();			
		
		<c:forEach items="${map}" var="loc">
			var cctv = new Object();	
			cctv.lon = "${loc.longitude}";
			cctv.lat = "${loc.latitude}";
			positions.push(cctv);
			count = count + 1;
		</c:forEach>
		
		var markerArray = new Array();
		var features = new Array();
		var bounds;
		
		var style_red = {
				fillColor:"#f2f2f2",
				fillOpacity:0.2,
				strokeColor: "#ff0000",
				strokeWidth: 1,
				strokeDashstyle: "solid",
				pointRadius: 60
			};
		
		function initTmap(){
			
			var coord, circle;
			
			// map 생성
			// Tmap.map을 이용하여, 지도가 들어갈 div, 넓이, 높이를 설정합니다.
			map = new Tmap.Map({div:'map_div', // map을 표시해줄 div
								width:'100%',  // map의 width 설정
								height:'850px' // map의 height 설정
								});
			
			map.setCenter(new Tmap.LonLat("127.04597379499731", "37.65369036685572").transform("EPSG:4326", "EPSG:3857"), 12);
			
			console.log(count); // db에서 불러온 데이터 개수
			
			markerLayer = new Tmap.Layer.Markers(); //마커 레이어 생성
			map.addLayer(markerLayer); //map에 마커 레이어 추가
			
			//map.events.register("click", map, onClick);
			
			console.log(map.getExtent().getCenterLonLat().transform("EPSG:3857", "EPSG:4326"));
			
			var size = new Tmap.Size(24, 38); //아이콘 크기 설정
			var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
			
			var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png', size, offset); //마커 아이콘 설정
			
			marker = new Tmap.Markers(map.getExtent().getCenterLonLat(), icon);
			markerArray.push(marker); // 마커 저장(지우기 위해)
			markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
			
			map.events.register("mouseup", map, move);
		}	
		
		/* function onClick(e) {
			var size = new Tmap.Size(24, 38); //아이콘 크기 설정
			var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
			
			var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png', size, offset); //마커 아이콘 설정
			
			marker = new Tmap.Markers(map.getExtent().getCenterLonLat(), icon);
			markerArray.push(marker); // 마커 저장(지우기 위해)
			markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
		} */
		
		function move() {
			
			var size = new Tmap.Size(24, 38); //아이콘 크기 설정
			var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
			
			var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png', size, offset); //마커 아이콘 설정
			
			bounds = map.getExtent();
			//console.log(bounds.getCenterLonLat().transform("EPSG:3857", "EPSG:4326"));
			
			marker = new Tmap.Markers(bounds.getCenterLonLat(), icon);
			markerArray.push(marker); // 마커 저장(지우기 위해)
			markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
			
			var mapArray = new Array();							
			
			for(var i=0; i<positions.length; i++){
				if(bounds.containsLonLat(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326","EPSG:3857")))
					mapArray.push(positions[i]);
			}
			
			if(mapArray.length > 500){
				markerLayer.clearMarkers();
				
				for(var i=0; i<mapArray.length; i=i+Math.floor(mapArray.length/500)){
					var size = new Tmap.Size(10, 10); //아이콘 크기 설정
					var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
					
					var icon = new Tmap.Icon('/resources/img/pointmark.png', size, offset); //마커 아이콘 설정
					
					marker = new Tmap.Markers(new Tmap.LonLat(mapArray[i].lon, mapArray[i].lat).transform("EPSG:4326", "EPSG:3857"), icon);
					markerArray.push(marker); // 마커 저장(지우기 위해)
					markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
				}
			}else {
				markerLayer.clearMarkers();
				
				for(var i=0; i<mapArray.length; i++){	
					var size = new Tmap.Size(10, 10); //아이콘 크기 설정
					var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
					
					var icon = new Tmap.Icon('/resources/img/pointmark.png', size, offset); //마커 아이콘 설정
					
					marker = new Tmap.Markers(new Tmap.LonLat(mapArray[i].lon, mapArray[i].lat).transform("EPSG:4326", "EPSG:3857"), icon);
					markerArray.push(marker); // 마커 저장(지우기 위해)
					markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
				}
			}				
			
			console.log(mapArray.length);
		}
		
		$(function (){
			initTmap();
			
			var body = document.body;
			
			$("body").on("mousewheel", function (event) {
				
				console.log(event.originalEvent.wheelDelta);
				
				setTimeout(function() {
					bounds = map.getExtent();
					
					var mapArray = new Array();							
					
					for(var i=0; i<positions.length; i++){
						if(bounds.containsLonLat(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326","EPSG:3857")))
							mapArray.push(positions[i]);
					}
					
					if(mapArray.length > 500){
						markerLayer.clearMarkers();
						
						for(var i=0; i<mapArray.length; i=i+Math.floor(mapArray.length/500)){
							var size = new Tmap.Size(10, 10); //아이콘 크기 설정
							var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
							
							var icon = new Tmap.Icon('/resources/img/pointmark.png', size, offset); //마커 아이콘 설정
							
							marker = new Tmap.Markers(new Tmap.LonLat(mapArray[i].lon, mapArray[i].lat).transform("EPSG:4326", "EPSG:3857"), icon);
							markerArray.push(marker); // 마커 저장(지우기 위해)
							markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
						}
					}else {
						markerLayer.clearMarkers();
						
						for(var i=0; i<mapArray.length; i++){	
							var size = new Tmap.Size(10, 10); //아이콘 크기 설정
							var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
							
							var icon = new Tmap.Icon('/resources/img/pointmark.png', size, offset); //마커 아이콘 설정
							
							marker = new Tmap.Markers(new Tmap.LonLat(mapArray[i].lon, mapArray[i].lat).transform("EPSG:4326", "EPSG:3857"), icon);
							markerArray.push(marker); // 마커 저장(지우기 위해)
							markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
						}
					}				
					
					console.log(mapArray.length);
				}, 800);
			});
			
			var map_div = document.getElementById('map_div');
		});
	</script>
</head>
<body>
	<div id="map_div"></div>
</body>
</html>