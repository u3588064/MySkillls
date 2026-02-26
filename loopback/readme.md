For Windows users(where in the {} is your variable):

powershell -ExecutionPolicy Bypass -File {YOUR DIR}\forWindows.ps1 -PromptText " {YOUR TASK} and output <promise>DONE</promise> only after {THE CRITERIA}" -CompletionPromise "DONE" -MaxIterations 10

An Example:
  powershell -ExecutionPolicy Bypass -File C:\forWindows.ps1 -PromptText
  "Crawl tophub.today and collect at least 1000 unique article links
  into tophub_links.json. Validate the JSON is readable and output
  <promise>DONE</promise> only after the file exists with >=1000
  items." -CompletionPromise "DONE" -MaxIterations 10


Original_Author: 肆〇柒/ForOhZen
Editor: Skedge
