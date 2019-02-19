function myFunction() {
  var x = document.getElementById("myTopnav");
  if (x.className === "topnav") {
    x.className += " responsive";
  } else {
    x.className = "topnav";
  }
}

(function () {
  var scrollContainer = document.querySelector('.scrollable'),
    scrollContentWrapper = document.querySelector('.scrollable .content-wrapper'),
    scrollContent = document.querySelector('.scrollable .content'),
    contentPosition = 0,
    scrollerBeingDragged = false,
    scroller,
    normalizedPosition,
    topPosition,
    scrollerHeight;

  function calculateScrollerHeight() {
    var visibleRatio = scrollContainer.offsetHeight / scrollContentWrapper.scrollHeight;
    return visibleRatio * scrollContainer.offsetHeight;
  }

  function moveScroller(evt) {
    var scrollPercentage = evt.target.scrollTop / scrollContentWrapper.scrollHeight;
    topPosition = scrollPercentage * (scrollContainer.offsetHeight - 5);
    scroller.style.top = topPosition + 'px';
  }

  function startDrag(evt) {
    normalizedPosition = evt.pageY;
    contentPosition = scrollContentWrapper.scrollTop;
    scrollerBeingDragged = true;
  }

  function stopDrag(evt) {
    scrollerBeingDragged = false;
  }

  function scrollBarScroll(evt) {
    if (scrollerBeingDragged === true) {
      var mouseDifferential = evt.pageY - normalizedPosition;
      var scrollEquivalent = mouseDifferential * (scrollContentWrapper.scrollHeight / scrollContainer.offsetHeight);
      scrollContentWrapper.scrollTop = contentPosition + scrollEquivalent;
    }
  }

  function createScroller() {
    scroller = document.createElement("div");
    scroller.className = 'scroller';

    scrollerHeight = calculateScrollerHeight();

    if (scrollerHeight / scrollContainer.offsetHeight < 1) {
      scroller.style.height = scrollerHeight + 'px';
      scrollContainer.appendChild(scroller);
      scrollContainer.className += ' showScroll';

      scroller.addEventListener('mousedown', startDrag);
      window.addEventListener('mouseup', stopDrag);
      window.addEventListener('mousemove', scrollBarScroll);
    }
  }

  createScroller();
  scrollContentWrapper.addEventListener('scroll', moveScroller);
}());
