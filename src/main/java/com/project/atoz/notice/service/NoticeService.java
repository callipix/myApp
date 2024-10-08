package com.project.atoz.notice.service;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import com.project.atoz.dto.NoticeDTO;
import com.project.atoz.dto.SearchCondition;

public interface NoticeService {
	List<NoticeDTO> getAllNotices();

	List<NoticeDTO> findAllByEhcache();

	List<NoticeDTO> findByPage(HttpServletRequest request, int pageNumber);

//	List<NoticeDTO> findNoticesByDates(LocalDateTime startDate, LocalDateTime endDate);

	Integer getNoticeTotalCount();

	Integer getSearchNoticeResultCount(SearchCondition sc);

	List<NoticeDTO> getNoticeListByEhcache(SearchCondition sc);

	List<NoticeDTO> noticeSearchSelectPage2(SearchCondition sc);

}
