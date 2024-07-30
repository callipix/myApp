package com.project.myapp.errorboard.dao;

import com.project.myapp.dto.ErrorBoardDTO;
import com.project.myapp.dto.SearchCondition;

import java.util.List;

public interface ErrorBoardDAO {

    public int insertErrorBoardMapper(ErrorBoardDTO errorBoardDTO);

    public List<ErrorBoardDTO> getSearchSelectPage(SearchCondition sc);

    public int getSearchResultCount(SearchCondition sc);
}
