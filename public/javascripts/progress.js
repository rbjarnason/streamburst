function progressPercent(bar, percentage) {
  document.getElementById(bar).style.width =  parseInt(percentage*2)+"px";
  document.getElementById(bar).innerHTML= "<div align='center'>"+parseInt(percentage)+"%</div>"
}

function progressText(textDiv, text) {
  document.getElementById(textDiv).innerHTML= "<div align='center'><b>"+text+"</b></div>"
}
