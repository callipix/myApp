<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>자유게시판 글쓰기</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <script src="https://code.jquery.com/jquery-1.11.3.js"></script>
    <link rel="stylesheet" href="<c:url value='/css/style.css'/>">
    <link rel="stylesheet" href="https://cdn.ckeditor.com/ckeditor5/42.0.1/ckeditor5.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ckeditor5/42.0.1/translations/ko.js"></script>
</head>
<body>
<jsp:include page="../header.jsp"/>
<script>
    if (!accessToken) {
        alert("잘못된 접근!!");
        history.back();
    }
    let msg = "${msg}";
    let beforeImgAddressWrite = [];
</script>

<div>
    <div class="board-container">
        <div>
            <div class="test-container">
                <h2 class="writing-header">게시글 ${mode == "new" ? "쓰기" : "읽기"}</h2>
                <div class="btnList">
                    <c:if test="${boardDTO.writer eq loginId}">
                        <button type="button" id="removeBtn" class="btn btn-remove"><i class="fa fa-trash"></i> 삭제하기
                        </button>
                    </c:if>
                    <button type="button" id="listBtn" class="btn btn-list"><i class="fa fa-bars"></i> 목록으로</button>
                    <button type="button" id="writeBtn" class="btn btn-write"><i class="fa fa-pencil"></i> 게시글등록
                    </button>
                </div>
            </div>
        </div>
        <input type="hidden" name="bno" value="${boardDTO.bno}">

        <form id="newForm" class="form" action="<c:url value='/board/write'/>" method="post"
              enctype="multipart/form-data">
            <c:if test="${not empty boardDTO.bno}">
                <input type="hidden" id="bno" name="bno" value="<c:out value='${boardDTO.bno}'/>">
            </c:if>
            <input type="hidden" id="afterList" name="afterList">
            <div class="form-group">
                <label for="title">
                    <input class="form-control" name="title" id="title" type="text"
                           value="<c:out value='${boardDTO.title}'/>"
                           placeholder="  제목을 입력해 주세요." ${mode=="new" ? "" : "readonly='readonly'"}>
                </label>
            </div>
            <br>
            <div class="form-group">
                <label for="content">
                    <textarea name="content" id="content" rows="20"
                              placeholder=" 내용을 입력해 주세요." ${mode=="new" ? "" : "readonly='readonly'"}></textarea>
                </label><br>
            </div>
            <script type="importmap">
                {
                    "imports": {
                        "ckeditor5": "https://cdn.ckeditor.com/ckeditor5/42.0.1/ckeditor5.js",
                        "ckeditor5/": "https://cdn.ckeditor.com/ckeditor5/42.0.1/"
                    }
                }
            </script>
            <script type="module" src="<c:url value='/ckeditor5/write.js'/>"></script>
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
    const form = document.querySelector("#newForm");
    const afterList = document.querySelector('#afterList');

    $(document).ready(function () {
        let formCheck = function () {
            let content = editor.getData();
            if (form.title.value === "") {
                alert("제목을 입력해 주세요.");
                form.title.focus();
                return false;
            }
            if (content === "") {
                alert("내용을 입력해 주세요.");
                form.content.focus();
                return false;
            }
            return true;
        }
        $("#removeBtn").on("click", function () {
            if (!confirm("정말로 삭제하시겠습니까?")) {
                return;
            }
            let form = $("#form");
            form.attr("action", "<c:url value='/board/remove${searchCondition.queryString}'/>");
            form.attr("method", "post");
            form.submit();
        })

        $("#writeNewBtn").on("click", function () {
            location.href = "<c:url value='/board/write'/>";
        });
        $("#writeBtn").on("click", function () {

            let content = editor.getData();

            if (formCheck()) {
                let afterImgAddressWrite = getImageSrcFromData(editor.getData());
                let imageAddress = {
                    "beforeImgAddress": beforeImgAddressWrite,
                    "afterImgAddress": afterImgAddressWrite
                }
                afterList.value = afterImgAddressWrite;

                let boardDTO = {
                    "title": form.title.value,
                    "content": content
                }

                if (isImageAddressEmpty(imageAddress)) {

                    let boardMap = {
                        "boardDTO": boardDTO,
                        "afterList": afterImgAddressWrite
                    }
                    $.ajax({
                        url: '/contentImgCheck',
                        type: 'post',
                        xhrFields: {
                            withCredentials: true
                        },
                        headers: {
                            'access': accessToken,
                            'Content-Type': 'application/json'
                        },
                        data: JSON.stringify(imageAddress),
                        success: function (result) {
                            if (result != 1) {
                                return;
                            }
                            boardWrite(boardMap);
                            beforeImgAddressWrite = [];
                        },
                        error: function (response) {
                            console.log(response);
                        }
                    })
                } else {
                    let boardMap = {
                        "boardDTO": boardDTO,
                    }
                    boardWrite(boardMap);
                }
            }
        })

        function boardWrite(parameter) {
            $.ajax({
                url: '/board/write',
                type: 'post',
                xhrFields: {
                    withCredentials: true
                },
                headers: {
                    'access': accessToken,
                    'Content-Type': 'application/json'
                },
                data: JSON.stringify(parameter),
                success: function (response) {
                    if (response.msg === "WRT_OK") {
                        alert("성공적으로 등록되었습니다.");
                        location.href = response.redirectURL;
                    }
                },
                error: function (response) {
                    console.log(response);
                    if (response.msg === "WRT_ERR") {
                        alert("글쓰기가 실패하였습니다.");
                        location.href = response.redirectURL;
                    }
                }
            })
        }

        // 각 배열의 길이가 0인지 확인
        function isImageAddressEmpty(imageAddress) {

            const {beforeImgAddress, afterImgAddress} = imageAddress;

            // if (!Array.isArray(beforeImgAddress) || !Array.isArray(afterImgAddress)) {
            //     // 배열이 아닌경우
            //     return false;
            // }
            const isBeforeImgEmpty = beforeImgAddress.length === 0;
            const isAfterImgEmpty = afterImgAddress.length === 0;
            // 배열이 비어있는지 확인
            return isBeforeImgEmpty && isAfterImgEmpty ? false : true;
        }
    });

    listBtn.addEventListener('click', function () {
        location.href = '<c:url value="/board/boardList"/>';
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