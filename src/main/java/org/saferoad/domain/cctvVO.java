package org.saferoad.domain;

import lombok.Data;

@Data
public class cctvVO {
	
	private String address;
	private String installdiv;
	private int camcount;
	private String shootinfo;
	private double latitude;
	private double longitude;
}
