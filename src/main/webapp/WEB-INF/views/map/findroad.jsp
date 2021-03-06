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
    	var map, markerLayer;
    	var i = 0;
		// map 생성
		// Tmap.map을 이용하여, 지도가 들어갈 div, 넓이, 높이를 설정합니다.
		function initTmap() {
			map = new Tmap.Map({
					div : 'map_div', // map을 표시해줄 div
					width : "100%", // map의 width 설정
					height : "850px", // map의 height 설정
				});
			
			map.setCenter(new Tmap.LonLat("126.986072", "37.570028").transform("EPSG:4326", "EPSG:3857"), 15); //설정한 좌표를 "EPSG:3857"로 좌표변환한 좌표값으로 즁심점을 설정합니다.

			markerLayer = new Tmap.Layer.Markers("marker"); //마커 레이어 생성
			map.addLayer(markerLayer); //map에 마커 레이어 추가
			
			map.events.register("click", map, onClick);
		}
		
		var clonlat, s_lon, s_lat, e_lon, e_lat;
		var routeLayer, markerLayer, icon, marker_s, marker_e;
		
		function onClick(e){
			
			console.log(i);
			
			var size = new Tmap.Size(24, 38); //아이콘 크기 설정
			var offset = new Tmap.Pixel(-(size.w / 2), -size.h); //아이콘 중심점 설정
			
			if(i == 0){
				clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326"); //클릭 부분의 ViewPortPx를 LonLat 좌표로 변환합니다.	
				s_clon = clonlat.lon;
				s_clat = clonlat.lat;
				
				icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_s.png />', size, offset); //마커 아이콘 설정
				marker_s = new Tmap.Marker(new Tmap.LonLat(s_clon, s_clat).transform("EPSG:4326", "EPSG:3857"), icon); //설정한 좌표를 "EPSG:3857"로 좌표변환한 좌표값으로 설정합니다.
				markerLayer.addMarker(marker_s); //마커 레이어에 마커 추가
			}else if(i == 1){
				clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326"); //클릭 부분의 ViewPortPx를 LonLat 좌표로 변환합니다.
				e_clon = clonlat.lon;
				e_clat = clonlat.lat;
				
				icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_e.png />', size, offset); //마커 아이콘 설정
				marker_e = new Tmap.Marker(new Tmap.LonLat(e_clon, e_clat).transform("EPSG:4326", "EPSG:3857"), icon); //설정한 좌표를 "EPSG:3857"로 좌표변환한 좌표값으로 설정합니다.
				markerLayer.addMarker(marker_e); //마커 레이어에 마커 추가
				
				var headers = {}; 
				headers["appKey"]="e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"; //실행을 위한 키 입니다. 발급받으신 AppKey(서버키)를 입력하세요.
				$.ajax({
					method:"POST",
					headers : headers,
					url:"https://api2.sktelecom.com/tmap/routes/pedestrian?version=1&format=xml", //보행자 경로안내 api 요청 url입니다.
					async:false,
					data:{
						//출발지 위경도 좌표입니다.
						startX : s_clon,
						startY : s_clat,
						//목적지 위경도 좌표입니다.
						endX : e_clon,
						endY : e_clat,
						//경유지의 좌표입니다.
						//passList : "126.97734400000255,37.56895299999981_126.97741500000393,37.569000000000095",
						//출발지, 경유지, 목적지 좌표계 유형을 지정합니다.
						reqCoordType : "WGS84GEO",
						resCoordType : "EPSG3857",
						//각도입니다.
						angle : "172",
						//출발지 명칭입니다.
						startName : "출발지",
						//목적지 명칭입니다.
						endName : "도착지"
					},
					//데이터 로드가 성공적으로 완료되었을 때 발생하는 함수입니다.
					success:function(response){
						prtcl = response;
						
						// 결과 출력
						var innerHtml ="";
						var prtclString = new XMLSerializer().serializeToString(prtcl); //xml to String	
					    xmlDoc = $.parseXML( prtclString ),
					    $xml = $( xmlDoc ),
				    	$intRate = $xml.find("Document");
				    	
				    	var tDistance = "총 거리 : "+($intRate[0].getElementsByTagName("tmap:totalDistance")[0].childNodes[0].nodeValue/1000).toFixed(1)+"km,";
				    	var tTime = " 총 시간 : "+($intRate[0].getElementsByTagName("tmap:totalTime")[0].childNodes[0].nodeValue/60).toFixed(0)+"분";	
				
				    	$("#result").text(tDistance+tTime);
						
						prtcl=new Tmap.Format.KML({extractStyles:true, extractAttributes:true}).read(prtcl); //데이터(prtcl)를 읽고, 벡터 도형(feature) 목록을 리턴합니다.
						routeLayer = new Tmap.Layer.Vector("route"); // 백터 레이어 생성
						//표준 데이터 포맷인 KML을 Read/Write 하는 클래스 입니다.
						//벡터 도형(Feature)이 추가되기 직전에 이벤트가 발생합니다.
						routeLayer.events.register("beforefeatureadded", routeLayer, onBeforeFeatureAdded);
						        function onBeforeFeatureAdded(e) {
							        	var style = {};
							        	switch (e.feature.attributes.styleUrl) {
							        	case "#pointStyle":
								        	style.externalGraphic = "http://topopen.tmap.co.kr/imgs/point.png"; //렌더링 포인트에 사용될 외부 이미지 파일의 url입니다.
								        	style.graphicHeight = 16; //외부 이미지 파일의 크기 설정을 위한 픽셀 높이입니다.
								        	style.graphicOpacity = 1; //외부 이미지 파일의 투명도 (0-1)입니다.
								        	style.graphicWidth = 16; //외부 이미지 파일의 크기 설정을 위한 픽셀 폭입니다.
							        	break;
							        	default:
								        	style.strokeColor = "#ff0000"; //stroke에 적용될 16진수 color
								        	style.strokeOpacity = "1"; //stroke의 투명도(0~1)
								        	style.strokeWidth = "5"; //stroke의 넓이(pixel 단위)
							        	};
						        	e.feature.style = style;
						        }
						
						routeLayer.addFeatures(prtcl); //레이어에 도형을 등록합니다.
						map.addLayer(routeLayer); //맵에 레이어 추가
						
						map.zoomToExtent(routeLayer.getDataExtent()); //map의 zoom을 routeLayer의 영역에 맞게 변경합니다.
					},
					//요청 실패시 콘솔창에서 에러 내용을 확인할 수 있습니다.
					error:function(request,status,error){
						console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
			}else if(i == 2){
				markerLayer.destroy();
				routeLayer.destroy();
				
				markerLayer = new Tmap.Layer.Markers("marker"); //마커 레이어 생성
				map.addLayer(markerLayer); //map에 마커 레이어 추가
				
				i = -1;
			}
			
			i = i + 1;
		}
		
		function onClickEnd(e){
			
			
		}
		
		$(function() {
			initTmap();
		});
		 
    </script>
</head>
<body>
	<div id="map_div">
	</div>
	<p id="result"></p>
</body>
</html>