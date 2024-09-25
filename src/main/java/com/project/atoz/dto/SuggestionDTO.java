package com.project.atoz.dto;

import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@Builder
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class SuggestionDTO {

	private int sno;
	private String writer;
	private String password;
	private String content;
	private Date regDate;
	private Date upDate;

	public SuggestionDTO(String writer, String password, String content) {
		this.writer = writer;
		this.password = password;
		this.content = content;
	}

}
