window.addEventListener("cab:copytext", (e) => {
  const text = e.target.value;
  navigator.clipboard.writeText(text);
});
