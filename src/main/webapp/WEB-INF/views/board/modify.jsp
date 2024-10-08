<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>자유게시판 게시글수정</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <script src="https://code.jquery.com/jquery-1.11.3.js"></script>
    <link rel="stylesheet" href="<c:url value='/css/style.css'/>">
    <link rel="stylesheet" href="https://cdn.ckeditor.com/ckeditor5/42.0.2/ckeditor5.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ckeditor5/42.0.2/translations/ko.js"></script>
</head>
<body>
<jsp:include page="../header.jsp"/>
<script>
    let boardWriter = "${boardDTO.writer}";
    let beforeImgAddressModify = [];
    let msg = "${msg}";

    if(accessToken){
        $.ajax({
            url : '/tokenCheck',
            method : 'get',
            xhrFields: {
                withCredentials: true
            },
            headers :{
                'access': accessToken,
                'Content-Type': 'application/json;charset=utf-8'
            },
            dataType: "text",
            success : function(response){
                if(boardWriter != response){
                    alert("잘못된 접근입니다");
                    history.back();
                }
            }
        })
    } else {
        alert("로그인 후 이용하세요");
        history.back();
    }
</script>

<div>
    <div class="board-container">
        <div>
            <div class="test-container">
                <h2 class="writing-header">게시글 ${mode == "mod" ? "수정" : "읽기"}</h2>
                <%--                <c:if test="${mode eq 'new'}">--%>
                <%--                    <button type="button" id="writeNewBtn" class="btn btn-write"><i class="fa fa-pencil"></i>글쓰기</button>--%>
                <%--                </c:if>--%>
                <div class="btnList">
                            <button type="button" id="removeBtn" class="btn btn-remove"><i class="fa fa-trash"></i> 삭제하기
                            </button>
                            <button type="button" id="modifyBtn" class="btn btn-modify"><i class="fa fa-edit"></i> 수정등록
                            </button>
                            <button type="button" id="listBtn" class="btn btn-list"><i class="fa fa-bars"></i> 목록으로
                            </button>
                </div>
            </div>
        </div>

        <form id="form" class="form" action="<c:url value='/board/modify'/>" method="post"
              enctype="multipart/form-data">
            <input type="hidden" name="bno" value="${boardDTO.bno}">
            <c:if test="${not empty boardDTO.bno}">
                <input type="hidden" id="bno" name="bno" value="<c:out value='${boardDTO.bno}'/>">
            </c:if>
            <div class="form-group">
                <label for="title">
                    <input class="form-control" name="title" id="title" type="text"
                           value="<c:out value='${boardDTO.title}'/>"
                           placeholder="  제목을 입력해 주세요." ${mode=="new" ? "" : "readonly='readonly'"}>
                </label>
            </div>
            <br>

            <div class="form-group">
                <label for="modifyContent">
                    <textarea id="modifyContent" name="modifyContent" rows="20"
                              placeholder=" 내용을 입력해 주세요." ${mode=="mod" ? "" : "readonly='readonly'"}><c:out
                            value="${boardDTO.content}"/></textarea><br>
                </label>
            </div>
            <script type="importmap">
                {
                    "imports": {
                        "ckeditor5": "https://cdn.ckeditor.com/ckeditor5/42.0.2/ckeditor5.js",
                        "ckeditor5/": "https://cdn.ckeditor.com/ckeditor5/42.0.2/"
                    }
                }
            </script>
            <script type="module" src="<c:url value='/ckeditor5/modify.js'/>"></script>
        </form>

    </div>

    <div id="commentList">
        <ul>
            <c:forEach var="commentDTO" items="${commentList}">
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
                            <a href="#" class="btn-write" data-cno="${commentDTO.cno}" data-bno="${commentDTO.bno}"
                               data-pcno="${commentDTO.pcno}">답글쓰기</a>
                            <a href="#" class="btn-modify" data-cno="${commentDTO.cno}" data-bno="${commentDTO.bno}"
                               data-pcno="${commentDTO.pcno}">수정</a>
                            <a href="#" class="btn-delete" data-cno="${commentDTO.cno}" data-bno="${commentDTO.bno}"
                               data-pcno="${commentDTO.pcno}">삭제</a>
                        </div>
                    </div>
                </li>
            </c:forEach>
        </ul>
        <br>
        <div id="comment-writebox">
            <div class="commenter commenter-writebox">댓글인데 없네</div>
            <div class="comment-writebox-content">
                <textarea name="comment-content" id="commentText" cols="30" rows="3" placeholder="댓글을 남겨보세요"></textarea>
            </div>
            <div id="comment-writebox-bottom">
                <div class="register-box">
                    <button type="button" class="btn" id="btn-write-comment">등록</button>
                    <br>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="comment.jsp"/>
</div>
<script>
    let bno = "${boardDTO.bno}";
    const listBtn = document.querySelector('#listBtn');
    const form = document.querySelector("#form");
    let isReadonly = $("input[name=title]").attr('readonly');

    if (isReadonly === 'readonly') {
        $("input[name=title]").attr('readonly', false);
        $("textarea").attr('readonly', false);
    }

    $(document).ready(function () {

        let formCheck = function () {

            let modifyContent = editor.getData();

            if (form.title.value === "") {
                alert("제목을 입력해 주세요.");
                form.title.focus();
                return false;
            }
            if (modifyContent.value === "") {
                alert("내용을 입력해 주세요.");
                form.content.focus();
                return false;
            }
            return true;
        }

        $("#removeBtn").on("click", function () {
            if (!confirm("정말로 삭제 하시겠습니까?")) {
                return;
            }
            let form = $("#form");
            form.attr("action", "<c:url value='/board/remove${searchCondition.queryString}'/>");
            form.attr("method", "post");
            form.submit();
        })

        $("#modifyBtn").on("click", function () {

            <%--form.attr("action", "<c:url value='/board/modify${searchCondition.queryString}'/>");--%>
            // form.attr("method", "post");
            let content = editor.getData();
            let formData = new FormData();

            formData.append("title", form.title.value);
            formData.append("content", content);
            formData.append("bno", bno);

            if (formCheck()) {
                let afterImgAddress = getImageSrcFromData(editor.getData());
                let imageAddress = {
                    "beforeImgAddress": beforeImgAddressModify,
                    "afterImgAddress": afterImgAddress
                }
                $.ajax({
                    url: '/contentImgCheck',
                    type: 'post',
                    xhrFields: {
                        withCredentials: true
                    },
                    headers :{
                        'access': accessToken,
                        'Content-Type': 'application/json'
                    },
                    data: JSON.stringify(imageAddress),
                    success: function (result) {
                        beforeImgAddressModify = [];
                        if (result != 1) return;
                    }
                })
                $.ajax({
                    url : '/board/modify',
                    method : 'post',
                    xhrFields: {
                        withCredentials: true
                    },
                    headers :{
                        'access': accessToken,
                    },
                    contentType: false,
                    processData: false,
                    data: formData,
                    success: function (response) {
                        if (response.msg === "MOD_OK") {
                            alert("성공적으로 수정되었습니다.");
                            location.href = response.redirectURL;
                        }
                    },
                    error: function (response) {
                        alert(response);
                        if (response.msg === "MOD_ERR") {
                            alert("글수정이 실패하였습니다.");
                            location.href = response.redirectURL;
                        }
                    }
                })

                $('#modifyContent').attr('name', 'content');
                form.submit();
            }
        });

        <%--$("#writeNewBtn").on("click", function(){--%>
        <%--    location.href="<c:url value='/board/write'/>";--%>
        <%--});--%>
        <%--$("#writeBtn").on("click", function(){--%>
        <%--    let form = $("#form");--%>
        <%--    form.attr("action", "<c:url value='/board/write'/>");--%>
        <%--    form.attr("method", "post");--%>
        <%--    if(formCheck()){--%>
        <%--        form.submit();--%>

        <%--    }--%>
        <%--});--%>
        listBtn.addEventListener('click', function () {
            location.href = '<c:url value="/board/boardList"/>';
        })
    })

    function getImageSrcFromData(data) {
        // 게시물 등록시 최종 주소값
        let afterImgAddress = [];

        const parser = new DOMParser();
        const doc = parser.parseFromString(data, 'text/html');
        const imgElements = doc.querySelectorAll('img');

        imgElements.forEach(img => {
            afterImgAddress.push(img.src);
        });
        return afterImgAddress;
    }
</script>
</body>
</html>