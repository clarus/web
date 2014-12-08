# Compile the LaTeX reports.

reports = [
  "cv-english", "cv-french",
  "m2-reports-hoare", "m2-reports-main", "m2-reports-slides", "m2-reports-miniml",
  "phd-reports-toplevel", "phd-reports-slidesejcp2013", "phd-reports-proposal", "phd-reports-proposal2", "phd-reports-monad", "phd-reports-draft",
  "yale-reports-coqfu", "yale-reports-main", "yale-reports-queue"
]

def try(command)
  exit(1) unless system(command)
end

for report in reports do
  puts "#{report}:"
  try("curl -L https://bitbucket.org/guillaumeclaret/#{report}/get/default.tar.bz2 |tar -xj")
  try("mv guillaumeclaret-#{report}-* #{report}")
  try("cd #{report} && TERM=xterm make && cd ..")
end
