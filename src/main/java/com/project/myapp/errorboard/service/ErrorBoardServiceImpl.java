package com.project.myapp.errorboard.service;

import com.project.myapp.dto.ErrorBoardDTO;
import com.project.myapp.dto.FilesDTO;
import com.project.myapp.dto.SearchCondition;
import com.project.myapp.errorboard.dao.ErrorBoardDAO;
import com.project.myapp.utiles.AwsS3FileUploadService;
import com.project.myapp.utiles.FileUpload;
import com.project.myapp.vo.ErrLogFileDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ErrorBoardServiceImpl implements ErrorBoardService {

    ErrorBoardDAO errorBoardDAO;
    AwsS3FileUploadService awsS3FileUploadService;
    FileUpload fileUpload;

    @Autowired
    ErrorBoardServiceImpl(ErrorBoardDAO errorBoardDAO , AwsS3FileUploadService awsS3FileUploadService, FileUpload fileUpload){
        this.errorBoardDAO = errorBoardDAO;
        this.awsS3FileUploadService = awsS3FileUploadService;
        this.fileUpload = fileUpload;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertErrorBoardMapper(ErrorBoardDTO errorBoardDTO, List<String> afterList) throws Exception {
        // 게시글 등록
        List<Integer> fileNoList = new ArrayList<>();
        for(String fileKeyList : afterList){
            fileNoList.add(this.fileUpload.getFileNoKeyList(fileKeyList));
        }
        int result = errorBoardDAO.insertErrorBoardMapper(errorBoardDTO);

        // 최근에 작업했던(auto_increment값 가져오기)
        int selectKey = this.fileUpload.selectKey();

        for(Integer fileNo : fileNoList){
            FilesDTO filesDTO = new FilesDTO();
            filesDTO.setFile_no(fileNo);
            filesDTO.setPost_no(selectKey);
            filesDTO.setCategory_no(errorBoardDTO.getCategoryNo());
            result += this.fileUpload.updateImages(filesDTO);
        }
        return result;
    }

    @Override
    public List<ErrorBoardDTO> getSearchSelectPage(SearchCondition sc) throws Exception {
        // 게시글 페이징 + 검색
        return this.errorBoardDAO.getSearchSelectPage(sc);
    }

    @Override
    public int getSearchResultCount(SearchCondition sc) throws Exception {
        // 전체 게시글 수
        return this.errorBoardDAO.getSearchResultCount(sc);
    }

    @Override
    public ErrorBoardDTO getErrorBoardByErrBno(int errBno){
        // 특정 게시글 조회
        ErrorBoardDTO errorBoardDTO = this.errorBoardDAO.getErrorBoardByErrBno(errBno);
        // 게시글을 조회하면 조회수가 증가
        errorBoardDAO.increaseViewCount(errBno);
        return errorBoardDTO;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int delete(Integer errBno, String writer) throws Exception {
        System.out.println("errBno = " + errBno);
        // 게시글 삭제
        int result = errorBoardDAO.delete(errBno, writer);
        System.out.println("게시글만 삭제했을때 결과값, 1이 나와야함 = " + result);

        System.out.println("이미지 주소 삭제 결과 이미지 개수만큼 나와야함 = " + result);
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int update(ErrorBoardDTO errorBoardDTO) throws Exception {
        // 게시글 업데이트
        int result = errorBoardDAO.update(errorBoardDTO);

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int isCheckWriter(String writer, int errBno) {
        System.out.println("service writer = " + writer);
        System.out.println("service errBno = " + errBno);
        int result = this.errorBoardDAO.isCheckWriter(writer, errBno);
        System.out.println("service result = " + result);
        return result;
    }

}
