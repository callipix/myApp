<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page session="true"%>
<c:set var="loginId" value="${sessionScope.id}"/>
<c:set var="loginOutLink" value="${loginId=='' ? '/login/login' : '/login/logout'}"/>
<c:set var="loginOut" value="${loginId=='' ? 'Login' : loginId}"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <script src="https://code.jquery.com/jquery-1.11.3.js"></script>
    <link rel="stylesheet" href="<c:url value='/css/boardDetail.css'/>">
</head>
<body>
<jsp:include page="../header.jsp" />
<script>
    let msg = "${msg}";
</script>
<div>
    <div class="board-container">
        <div>
            <div class="test-container">
            <h2 class="writing-header">게시글 ${mode eq "new" ? "쓰기" : "읽기"}</h2>
<%--                <c:if test="${mode eq 'new'}">--%>
<%--                    <button type="button" id="writeNewBtn" class="btn btn-write"><i class="fa fa-pencil"></i>글쓰기</button>--%>
<%--                </c:if>--%>
                <div class="btnList">
                    <c:if test="${boardDTO.writer eq loginId}">
                        <button type="button" id="modifyBtn" class="btn btn-modify"><i class="fa fa-edit"></i> 수정하기</button>
                        <button type="button" id="removeBtn" class="btn btn-remove"><i class="fa fa-trash"></i> 삭제하기</button>
                    </c:if>
                        <button type="button" id="listBtn" class="btn btn-list"><i class="fa fa-bars"></i> 목록으로</button>
                </div>
            </div>
        </div>
        <form id="form" class="form" action="<c:url value='/board/write'/>" method="post">
            <c:if test="${not empty boardDTO.bno}">
                <input type="hidden" id="bno" name="bno" value="<c:out value='${boardDTO.bno}'/>">
            </c:if>
            <input name="title" id="title" type="text" value="<c:out value='${boardDTO.title}'/>" placeholder="  제목을 입력해 주세요." ${mode=="new" ? "" : "readonly='readonly'"}><br>

            <textarea id="content" name="content" rows="20" placeholder=" 내용을 입력해 주세요." ${mode=="new" ? "" : "readonly='readonly'"}><c:out value="${boardDTO.content}"/></textarea><br>

            <c:if test="${mode eq 'new'}">
                <button type="button" id="writeBtn" class="btn btn-write"><i class="fa fa-pencil"></i> 등록하기</button>
            </c:if>
        </form>

        <div id="commentList">
            <ul>
                <c:forEach var = "commentDTO" items="${commentList}">
                <li class="comment-item" data-cno="${commentDTO.cno}" data-bno="${commentDTO.bno}">
                        <span class="comment-img">
                            <i class="fa fa-user-circle" aria-hidden="true"></i>
                        </span>
                    <div class="comment-area">
                        <div class="commenter">${commentDTO.commenter}</div>
                        <div class="comment-content">${commentDTO.comment}
                        </div>
                        <div class="comment-bottom">
                            <span class="up_date">${commentDTO.up_date}</span>
                            <a href="#" class="btn-write"  data-cno="${commentDTO.cno}" data-bno="${commentDTO.bno}" data-pcno="${commentDTO.pcno}">답글쓰기</a>
                            <a href="#" class="btn-modify" data-cno="${commentDTO.cno}" data-bno="${commentDTO.bno}" data-pcno="${commentDTO.pcno}">수정</a>
                            <a href="#" class="btn-delete" data-cno="${commentDTO.cno}" data-bno="${commentDTO.bno}" data-pcno="${commentDTO.pcno}">삭제</a>
                        </div>
                    </div>
                </li>
                </c:forEach>
            </ul>
            <br>
            <div id="comment-writebox">
                <div class="commenter commenter-writebox">댓글인데 없네</div>
                <div class="comment-writebox-content">
                    <textarea name="comment-content" id="comment-content" cols="30" rows="3" placeholder="댓글을 남겨보세요"></textarea>
                </div>
                <div id="comment-writebox-bottom">
                    <div class="register-box">
                        <button type="button" class="btn" id="btn-write-comment">등록</button>
                        <br>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="comment.jsp" />
    </div>
</div>

<script>
$(document).ready(function(){

    let formCheck = function() {

        let form = document.getElementById("form");

        if(form.title.value ==='') {
            alert("제목을 입력해 주세요.");
            form.title.focus();
            return false;
        }
        if(form.content.value==='') {
            alert("내용을 입력해 주세요.");
            form.content.focus();
            return false;
        }
        return true;
    }
    $("#btn-write-comment").on("click", function(){

        let comment = document.querySelector("#comment-content");

        let commentDTO = {
            comment : comment.value
        }
        if(!confirm("등록하시겠습니까?")){
            return;
        }

        $.ajax({
            url : '/myApp/comments',
            type : 'post',
            dataType : "application:utf-8",
            data : JSON.stringify(commentDTO),
            success : function(result){
                console.log("result = " + result);
            }
        })

    })

    $("#removeBtn").on("click", function(){
        if(!confirm("정말로 삭제하시겠습니까?")){
            return;
        }
        let form = $("#form");
        form.attr("action", "<c:url value='/board/remove${searchCondition.queryString}'/>");
        form.attr("method" , "post");
        form.submit();
    })

    $("#modifyBtn").on("click", function(){
        let form = $("#form");
        let isReadonly = $("input[name=title]").attr('readonly');

        // 1. 읽기 상태이면, 수정 상태로 변경
        if(isReadonly === 'readonly'){

            $(".writing-header").html("글수정");
            $("input[name=title]").attr('readonly', false);
            // ↕ 같은거 아닌가? isReadonly.attr('readonly', false);
            $("textarea").attr('readonly', false);
            $("#modifyBtn").html("<i class='fa fa-pencil'></i> 등록하기");
            $("#listBtn").css('display', 'none');

            // ↓↓↓↓↓↓↓ 바닐라스크립트
            // document.querySelector(".writing-header").innerHTML = "글수정";
            // document.querySelector("input[name=title]").removeAttribute('readonly');
            // document.querySelector("textarea").removeAttribute('readonly');
            // document.querySelector("#modifyBtn").innerHTML = "<i class='fa fa-pencil'></i> 수정하기";
            // document.querySelector("#listBtn").style.display = 'none';  // 이 줄을 추가하여 listBtn의 display를 none으로 설정합니다.
            return;
        }
        // 2. 수정 상태이면, 수정된 내용을 서버로 전송
        form.attr("action","<c:url value='/board/modify${searchCondition.queryString}'/>");
        form.attr("method", "post");
        if(formCheck())
            form.submit();
    })
    $("#writeNewBtn").on("click", function(){
        location.href="<c:url value='/board/write'/>";
    });
    $("#writeBtn").on("click", function(){
        let form = $("#form");
        form.attr("action", "<c:url value='/board/write'/>");
        form.attr("method", "post");
        if(formCheck())
            form.submit();
    });
        listBtn.addEventListener('click', function () {
            location.href = '<c:url value="/board/boardList"/>';
        })
})
</script>
</body>
</html>
