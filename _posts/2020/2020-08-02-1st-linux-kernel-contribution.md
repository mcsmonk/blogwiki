---
layout  : post
title   : 리눅스 커널 첫 컨트리뷰션 과정
summary : 리눅스 커널 패치 제출 및 과정 정리
date    : 2020-08-02 20:00:00 +0900
updated : 2020-09-21 22:00:00 +0900
tag     : study linux record
resource: DE/BDA86C-A752-4D5B-BD20-E8DB62D1FA2C
toc     : true
comment : true
public  : true
---


# 첫 커널 패치 제출 시도 1 : 2020.08.02

- [iamroot16](https://github.com/iamroot16/linux) 스터디 진행 중에 발견한 버그를 경험삼아 커널 패치 제출 과정을 해봄
- [AustinKim](http://rousalome.egloos.com/)님의 잘 정리된 [커널 제출 방법](https://kldp.org/node/162104)을 그대로 수행
- 위 글이 있지만 내가 직접 리눅스 커널 패치 제출을 위해 사용한 터미널 명령어 기록을 위해 정리

## 과정
- [iamroot16](https://github.com/iamroot16/linux) 스터디 진행 중에 버그 발견
    - percpu 관련 함수인 pcpu_alloc_first_chunk 함수에서 메모리 할당을 위한 사이즈 계산시 아래 부분에 관련한 버그 존재
    ```
    // in mm/percpu.c
    1104         /* allocate chunk */
    1105         alloc_size = sizeof(struct pcpu_chunk) +
    1106                 BITS_TO_LONGS(region_size >> PAGE_SHIFT);
    1107         chunk = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
    ...
    1142         /* manage populated page bitmap */
    1143         chunk->immutable = true;
    1144         bitmap_fill(chunk->populated, chunk->nr_pages);
    ...
    230 static inline void bitmap_fill(unsigned long *dst, unsigned int nbits)
    231 {
    232         unsigned int len = BITS_TO_LONGS(nbits) * sizeof(unsigned long);
    233         memset(dst, 0xff, len);
    234 }
    ```

- 언제 제출해볼 기회가 생길지 몰라서 커널 패치 제출 방법에 대해 자세히 알아보지 않았는데 갑자기 해보고 싶어져 마음만 급했던 상황
- [AustinKim](http://rousalome.egloos.com/)님의 [글](https://kldp.org/node/162104)을 참고하였지만 마지막에 구글 2단계 인증으로 인해 마지막 제출 부분에 문제를 겪었음
    1. 커널 패치 제출물 준비
        ```
        $ git add ./mm/percpu.c
        $ git commit -m 'mm/percpu.c: Modify size of populated bitmap of chunk for memory allocation'
        $ git commit --amend --author="Sunghyun Jin <mcsmonk@gmail.com>"
        ...
        Write here a description on your patch
        ...

        Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>

        $ git log -p
        $ git format-patch -1
        $ git format-patch -o /tmp/ head^
        ```
    2. 커널 패치 제출물 컨벤션 검사
        ```
        $ ./scripts/checkpatch.pl ./0001-mm-percpu.c-Modify-size-of-populated-bitmap-of-chunk.patch
        total: 0 errors, 0 warnings, 8 lines checked

        ./0001-mm-percpu.c-Modify-size-of-populated-bitmap-of-chunk.patch has no obvious style problems and is ready for submission.
        ```
    3. 관련 메인테이너 확인
        ```
        $ git show HEAD | perl scripts/get_maintainer.pl --separator , --nokeywords --nogit --nogit-fallback --norolestats --nol
        Dennis Zhou <dennis@kernel.org>,Tejun Heo <tj@kernel.org>,Christoph Lameter <cl@linux.com>,Andrew Morton <akpm@linux-foundation.org>
        $ perl scripts/get_maintainer.pl --separator , --nokeywords --nogit --nogit-fallback --norolestats --nol -f ./mm/percpu.c
        Dennis Zhou <dennis@kernel.org>,Tejun Heo <tj@kernel.org>,Christoph Lameter <cl@linux.com>,Andrew Morton <akpm@linux-foundation.org>
        ```
    4. 커널 패치 제출 2020.08.02 시도
        - 구글 2단계 인증 때문에 mutt으로 계속 실패해서 git send-email로 시도함

        ```
        $ sudo apt-get install git-email
        $ git send-email --annotate HEAD^
        $ git send-email head^
        /tmp/QUJQQ7b5bp/0001-mm-percpu.c-Modify-size-of-populated-bitmap-of-chunk.patch
        To whom should the emails be sent (if anyone)? linux-kernel@vger.kernel.org
        Message-ID to be used as In-Reply-To for the first email (if any)? dennis@kernel.org; tj@kernel.org; cl@linux.com; akpm@linux-foundation.org
        (mbox) Adding cc: Sunghyun Jin <mcsmonk@gmail.com> from line 'From: Sunghyun Jin <mcsmonk@gmail.com>'
        (body) Adding cc: Sunghyun Jin <mcsmonk@gmail.com> from line 'Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>'

        From: mcsmonk <mcsmonk@gmail.com>
        To: linux-kernel@vger.kernel.org
        Cc: Sunghyun Jin <mcsmonk@gmail.com>
        Subject: [PATCH] mm/percpu.c: Modify size of populated bitmap of chunk for memory allocation
        Date: Sun,  2 Aug 2020 21:12:43 +0900
        Message-Id: <20200802121243.15148-1-mcsmonk@gmail.com>
        X-Mailer: git-send-email 2.17.1
        In-Reply-To: <dennis@kernel.org; tj@kernel.org; cl@linux.com; akpm@linux-foundation.org>
        References: <dennis@kernel.org; tj@kernel.org; cl@linux.com; akpm@linux-foundation.org>

            The Cc list above has been expanded by additional
            addresses found in the patch commit message. By default
            send-email prompts before sending whenever this occurs.
            This behavior is controlled by the sendemail.confirm
            configuration setting.

            For additional information, run 'git send-email --help'.
            To retain the current behavior, but squelch this message,
            run 'git config --global sendemail.confirm auto'.

        Send this email? ([y]es|[n]o|[q]uit|[a]ll): y
        OK. Log says:
        Server: smtp.googlemail.com
        MAIL FROM:<mcsmonk@gmail.com>
        RCPT TO:<linux-kernel@vger.kernel.org>
        RCPT TO:<mcsmonk@gmail.com>
        From: mcsmonk <mcsmonk@gmail.com>
        To: linux-kernel@vger.kernel.org
        Cc: Sunghyun Jin <mcsmonk@gmail.com>
        Subject: [PATCH] mm/percpu.c: Modify size of populated bitmap of chunk for memory allocation
        Date: Sun,  2 Aug 2020 21:12:43 +0900
        Message-Id: <20200802121243.15148-1-mcsmonk@gmail.com>
        X-Mailer: git-send-email 2.17.1
        In-Reply-To: <dennis@kernel.org; tj@kernel.org; cl@linux.com; akpm@linux-foundation.org>
        References: <dennis@kernel.org; tj@kernel.org; cl@linux.com; akpm@linux-foundation.org>

        Result: 250
        ```

## 결과
- [https://marc.info/?l=linux-kernel&m=159637037815556&w=2](https://marc.info/?l=linux-kernel&m=159637037815556&w=2)
- [https://lkml.org/lkml/2020/8/2/94](https://lkml.org/lkml/2020/8/2/94)
- 급한 마음에 리눅스 커널 패치 컨벤션도 무시해버림
- 제출한 커밋이 제대로 된건지 피드백 자체가 없어서 모르겠음
    - 제출한 패치가 잘못된 수정인지, 제대로 받을 사람에게 보내진건지, 컨벤션 미준수로 스킵 당한건지 ... 

## TODOLIST
    1. 커널 컨벤션 확인
    2. 커널 패치 제출글 확인
    3. mutt, git send-email 사용법 공부

## 문제 해결 방법
- 구글 2단계 인증으로 인한 문제 해결 방법
    - (구글 계정 - 보안 - 앱 비밀번호) 설정을 통해 만든 비밀번호 사용



# 첫 커널 패치 제출 시도 2 : 2020.09.03

[SeongJae Park](https://sjp38.github.io/ko/)님의 커널 패치 제출에 대한 다른 글[link](https://dry-kiss.blogspot.com/2012/10/blog-post.html)을 참고하여 다시 제출

## 과정
```
$ git commit -m 'mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation'
[master 067d96099555] mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git commit --amend --author="Sunghyun Jin <mcsmonk@gmail.com>"
[master 8dc12c30b6e3] mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation
 Author: Sunghyun Jin <mcsmonk@gmail.com>
 Date: Thu Sep 3 20:50:53 2020 +0900
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git log -p
commit 8dc12c30b6e31805e64fe2151464f97741b98e87 (HEAD -> master)
Author: Sunghyun Jin <mcsmonk@gmail.com>
Date:   Thu Sep 3 20:50:53 2020 +0900

    mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation

    Variable populated, which is a member of struct pcpu_chunk, is used as a
    unit of size of unsigned long.
    However, size of populated is miscounted. So, I fix this minor part.

    Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>

diff --git a/mm/percpu.c b/mm/percpu.c
index f4709629e6de..1ed1a349eab8 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1316,7 +1316,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,

        /* allocate chunk */
        alloc_size = sizeof(struct pcpu_chunk) +
-               BITS_TO_LONGS(region_size >> PAGE_SHIFT);
+               BITS_TO_LONGS(region_size >> PAGE_SHIFT) * sizeof(unsigned long);
        chunk = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
        if (!chunk)
                panic("%s: Failed to allocate %zu bytes\n", __func__,

$ git log -1
commit 8dc12c30b6e31805e64fe2151464f97741b98e87 (HEAD -> master)
Author: Sunghyun Jin <mcsmonk@gmail.com>
Date:   Thu Sep 3 20:50:53 2020 +0900

    mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation

    Variable populated, which is a member of struct pcpu_chunk, is used as a
    unit of size of unsigned long.
    However, size of populated is miscounted. So, I fix this minor part.

    Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>

$ cat ./0001-mm-percpu.c-Modify-calculation-of-size-of-populated-.patch
From 8dc12c30b6e31805e64fe2151464f97741b98e87 Mon Sep 17 00:00:00 2001
From: Sunghyun Jin <mcsmonk@gmail.com>
Date: Thu, 3 Sep 2020 20:50:53 +0900
Subject: [PATCH] mm/percpu.c: Modify calculation of size of populated bitmap
 of chunk for memory allocation

Variable populated, which is a member of struct pcpu_chunk, is used as a
unit of size of unsigned long.
However, size of populated is miscounted. So, I fix this minor part.

Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>
---
 mm/percpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index f4709629e6de..1ed1a349eab8 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1316,7 +1316,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,

        /* allocate chunk */
        alloc_size = sizeof(struct pcpu_chunk) +
-               BITS_TO_LONGS(region_size >> PAGE_SHIFT);
+               BITS_TO_LONGS(region_size >> PAGE_SHIFT) * sizeof(unsigned long);
        chunk = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
        if (!chunk)
                panic("%s: Failed to allocate %zu bytes\n", __func__,
--
2.17.1

$ ./scripts/checkpatch.pl ./0001-mm-percpu.c-Modify-calculation-of-size-of-populated-.patch
total: 0 errors, 0 warnings, 8 lines checked

./0001-mm-percpu.c-Modify-calculation-of-size-of-populated-.patch has no obvious style problems and is ready for submission.
$  ./scripts/get_maintainer.pl ./0001-mm-percpu.c-Modify-calculation-of-size-of-populated-.patch
Dennis Zhou <dennis@kernel.org> (maintainer:PER-CPU MEMORY ALLOCATOR)
Tejun Heo <tj@kernel.org> (maintainer:PER-CPU MEMORY ALLOCATOR)
Christoph Lameter <cl@linux.com> (maintainer:PER-CPU MEMORY ALLOCATOR)
Andrew Morton <akpm@linux-foundation.org> (maintainer:MEMORY MANAGEMENT)
linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
linux-kernel@vger.kernel.org (open list)
$ git send-email --to tj@kernel.org ./0001-mm-percpu.c-Modify-calculation-of-size-of-populated-.patch
./0001-mm-percpu.c-Modify-calculation-of-size-of-populated-.patch
(mbox) Adding cc: Sunghyun Jin <mcsmonk@gmail.com> from line 'From: Sunghyun Jin <mcsmonk@gmail.com>'
(body) Adding cc: Sunghyun Jin <mcsmonk@gmail.com> from line 'Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>'

From: mcsmonk <mcsmonk@gmail.com>
To: tj@kernel.org
Cc: Sunghyun Jin <mcsmonk@gmail.com>
Subject: [PATCH] mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation
Date: Thu,  3 Sep 2020 20:53:43 +0900
Message-Id: <20200903115343.1316-1-mcsmonk@gmail.com>
X-Mailer: git-send-email 2.17.1

    The Cc list above has been expanded by additional
    addresses found in the patch commit message. By default
    send-email prompts before sending whenever this occurs.
    This behavior is controlled by the sendemail.confirm
    configuration setting.

    For additional information, run 'git send-email --help'.
    To retain the current behavior, but squelch this message,
    run 'git config --global sendemail.confirm auto'.

Send this email? ([y]es|[n]o|[q]uit|[a]ll): y
OK. Log says:
Server: smtp.googlemail.com
MAIL FROM:<mcsmonk@gmail.com>
RCPT TO:<tj@kernel.org>
RCPT TO:<mcsmonk@gmail.com>
From: mcsmonk <mcsmonk@gmail.com>
To: tj@kernel.org
Cc: Sunghyun Jin <mcsmonk@gmail.com>
Subject: [PATCH] mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation
Date: Thu,  3 Sep 2020 20:53:43 +0900
Message-Id: <20200903115343.1316-1-mcsmonk@gmail.com>
X-Mailer: git-send-email 2.17.1

Result: 250

$ git send-email --to linux-mm@kvack.org ./0001-mm-percpu.c-Modify-calculation-of-size-of-populated-.patch
./0001-mm-percpu.c-Modify-calculation-of-size-of-populated-.patch
(mbox) Adding cc: Sunghyun Jin <mcsmonk@gmail.com> from line 'From: Sunghyun Jin <mcsmonk@gmail.com>'
(body) Adding cc: Sunghyun Jin <mcsmonk@gmail.com> from line 'Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>'

From: mcsmonk <mcsmonk@gmail.com>
To: linux-mm@kvack.org
Cc: Sunghyun Jin <mcsmonk@gmail.com>
Subject: [PATCH] mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation
Date: Thu,  3 Sep 2020 20:53:43 +0900
Message-Id: <20200903124116.1668-1-mcsmonk@gmail.com>
X-Mailer: git-send-email 2.17.1

    The Cc list above has been expanded by additional
    addresses found in the patch commit message. By default
    send-email prompts before sending whenever this occurs.
    This behavior is controlled by the sendemail.confirm
    configuration setting.

    For additional information, run 'git send-email --help'.
    To retain the current behavior, but squelch this message,
    run 'git config --global sendemail.confirm auto'.

Send this email? ([y]es|[n]o|[q]uit|[a]ll): y
OK. Log says:
Server: smtp.googlemail.com
MAIL FROM:<mcsmonk@gmail.com>
RCPT TO:<linux-mm@kvack.org>
RCPT TO:<mcsmonk@gmail.com>
From: mcsmonk <mcsmonk@gmail.com>
To: linux-mm@kvack.org
Cc: Sunghyun Jin <mcsmonk@gmail.com>
Subject: [PATCH] mm/percpu.c: Modify calculation of size of populated bitmap of chunk for memory allocation
Date: Thu,  3 Sep 2020 20:53:43 +0900
Message-Id: <20200903115343.1316-1-mcsmonk@gmail.com>
X-Mailer: git-send-email 2.17.1

Result: 250
```

## 결과
- [https://lore.kernel.org/linux-mm/20200903124116.1668-1-mcsmonk@gmail.com/T/#u](https://lore.kernel.org/linux-mm/20200903124116.1668-1-mcsmonk@gmail.com/T/#u)

```
From: Dennis Zhou <dennis@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mcsmonk <mcsmonk@gmail.com>, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/percpu.c: Modify calculation of size of populated
 bitmap of chunk for memory allocation
Message-ID: <20200903154626.GA1665298@google.com>
References: <20200903124116.1668-1-mcsmonk@gmail.com>
 <a314b5ff-599f-b580-9bf2-e6c9b95183ea@suse.cz>
...
List-ID: <linux-mm.kvack.org>
Archived-At: <https://lore.kernel.org/linux-mm/20200903154626.GA1665298@google.com/>
List-Archive: <https://lore.kernel.org/linux-mm/>
List-Post: <mailto:linux-mm@kvack.org>

Hello Vlastimil and Sunghyun,

On Thu, Sep 03, 2020 at 03:46:33PM +0200, Vlastimil Babka wrote:
> On 9/3/20 2:41 PM, mcsmonk wrote:
> From: Sunghyun Jin <mcsmonk@gmail.com>
> 
> Variable populated, which is a member of struct pcpu_chunk, is used as a
> unit of size of unsigned long.
> However, size of populated is miscounted. So, I fix this minor part.

> +CC folks who touched it last

Thanks for CCing me.

> Nice find! Did you observe e.g. a panic that can be used in the commit log? Or
> were we always lucky thanks to alignment?

Well that is indeed awkward. Luckily the first chunk is a bit special
and only holds 7 dynamic pages. Additionally, the allocation rounds to
SMP_CACHE_BYTES so that would give us 8 bytes to play with as
struct pcpu_chunk is 120 bytes. So, while technically (wrong) the
1 byte was sufficient and the additional buffer is why at least I never
got a panic report to today.

> Is there perhaps a commit that introduced the bug and we can use it as Fixes:?
> My brief look suggests 8ab16c43ea79 ("percpu: change the number of pages marked
> in the first_chunk pop bitmap")

That is the right commit. I'll pick this up and add the fixes line.

> Thanks!

Thanks,
Dennis

> > Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>
> > ---
> >  mm/percpu.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/percpu.c b/mm/percpu.c
> > index f4709629e6de..1ed1a349eab8 100644
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -1316,7 +1316,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
> >  
> >  	/* allocate chunk */
> >  	alloc_size = sizeof(struct pcpu_chunk) +
> > -		BITS_TO_LONGS(region_size >> PAGE_SHIFT);
> > +		BITS_TO_LONGS(region_size >> PAGE_SHIFT) * sizeof(unsigned long);
> >  	chunk = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
> >  	if (!chunk)
> >  		panic("%s: Failed to allocate %zu bytes\n", __func__,
```

- Updated 2020. Sep. 04
    - 밤에 커밋하니까 미국 시간 업무 시간대라 빠르게 반응 옴
    - 기술적으로 문제 없던 부분이라도 유의미해서인지 잘 반응해줌

## 최종 결과 2020. Sep. 21
- [https://github.com/torvalds/linux/commit/b3b33d3c43bbe0177d70653f4e889c78cc37f097](https://github.com/torvalds/linux/commit/b3b33d3c43bbe0177d70653f4e889c78cc37f097)

```
This is a note to let you know that I've just added the patch titled

    percpu: fix first chunk size calculation for populated bitmap

to the 5.8-stable tree which can be found at:
    [http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary](http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary)

The filename of the patch is:
    percpu-fix-first-chunk-size-calculation-for-populated-bitmap.patch
and it can be found in the queue-5.8 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


From b3b33d3c43bbe0177d70653f4e889c78cc37f097 Mon Sep 17 00:00:00 2001
From: Sunghyun Jin <mcsmonk@gmail.com>
Date: Thu, 3 Sep 2020 21:41:16 +0900
Subject: percpu: fix first chunk size calculation for populated bitmap

From: Sunghyun Jin <mcsmonk@gmail.com>

commit b3b33d3c43bbe0177d70653f4e889c78cc37f097 upstream.

Variable populated, which is a member of struct pcpu_chunk, is used as a
unit of size of unsigned long.
However, size of populated is miscounted. So, I fix this minor part.

Fixes: 8ab16c43ea79 ("percpu: change the number of pages marked in the first_chunk pop bitmap")
Cc: <stable@vger.kernel.org> # 4.14+
Signed-off-by: Sunghyun Jin <mcsmonk@gmail.com>
Signed-off-by: Dennis Zhou <dennis@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
mm/percpu.c |    2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1300,7 +1300,7 @@ static struct pcpu_chunk * __init pcpu_a

        /* allocate chunk */
        alloc_size = sizeof(struct pcpu_chunk) +
-               BITS_TO_LONGS(region_size >> PAGE_SHIFT);
+               BITS_TO_LONGS(region_size >> PAGE_SHIFT) * sizeof(unsigned long);
        chunk = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
        if (!chunk)
                panic("%s: Failed to allocate %zu bytes\n", __func__,


Patches currently in stable-queue which might be from mcsmonk@gmail.com are

queue-5.8/percpu-fix-first-chunk-size-calculation-for-populated-bitmap.patch
queue-5.4/percpu-fix-first-chunk-size-calculation-for-populated-bitmap.patch
queue-4.19/percpu-fix-first-chunk-size-calculation-for-populated-bitmap.patch
queue-4.14/percpu-fix-first-chunk-size-calculation-for-populated-bitmap.patch
```

# 참고 사이트
- Linux Kernel Official Doc
    - [https://www.kernel.org/doc/html/latest/process/submitting-patches.html](https://www.kernel.org/doc/html/latest/process/submitting-patches.html)
- [AustinKim](http://rousalome.egloos.com/)님의 커널 제출 방법
    - [https://kldp.org/node/162104](https://kldp.org/node/162104)
- [SeongJae Park](https://sjp38.github.io/ko/)님의 커널 제출 방법
    - [https://dry-kiss.blogspot.com/2012/10/blog-post.html](https://dry-kiss.blogspot.com/2012/10/blog-post.html)
- github 사이트에서 PR시 Linux KernelPRBot의 답장
    - [https://github.com/ajdlinux/KernelPRBot/blob/master/message.md](https://github.com/ajdlinux/KernelPRBot/blob/master/message.md)
- KernelNewbies: Outreachyfirstpatch
    - [https://kernelnewbies.org/Outreachyfirstpatch](https://kernelnewbies.org/Outreachyfirstpatch)
- git send-email
    - [https://riptutorial.com/ko/git/example/16977/gmail%EC%97%90%EC%84%9C-git-send-email-%EC%82%AC%EC%9A%A9](https://riptutorial.com/ko/git/example/16977/gmail%EC%97%90%EC%84%9C-git-send-email-%EC%82%AC%EC%9A%A9)