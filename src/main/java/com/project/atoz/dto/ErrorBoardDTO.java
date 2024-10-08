package com.project.atoz.dto;

import java.util.Date;

import org.jetbrains.annotations.NotNull;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class ErrorBoardDTO {

	private int rownum;
	@EqualsAndHashCode.Include
	private int errBno;
	private String errCode;
	@NotNull
	private String title;
	@NotNull
	private String content;
	@NotNull
	private String writer;
	private int viewCnt;
	private int commentCnt;
	private Date regDate;
	private Date upDate;
	@EqualsAndHashCode.Include
	private final int categoryNo = 2;
	private String errBoardThum;

	public ErrorBoardDTO() {
	}

	public ErrorBoardDTO(String errCode, String title, String content, String writer) {
		this.errCode = errCode;
		this.title = title;
		this.content = content;
		this.writer = writer;
	}

	public ErrorBoardDTO(String errCode, String title, String content, String writer, String errBoardThum) {
		this.errCode = errCode;
		this.title = title;
		this.content = content;
		this.writer = writer;
		this.errBoardThum = errBoardThum;
	}

}
