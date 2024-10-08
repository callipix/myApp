package com.project.atoz.suggestion.service;

import java.util.List;
import java.util.Map;

import com.project.atoz.dto.SuggestionDTO;

public interface SuggestionService {

	List<SuggestionDTO> getSelectPage(Map map);

	SuggestionDTO suggestCommentInsert(SuggestionDTO suggestionDTO);

	int updateSuggestComment(SuggestionDTO suggestionDTO);

	int suggestCommentDelete(String password, int sno);

	int suggestCommentCount();

	int isEqualsIdNPass(int sno, String password);

}
