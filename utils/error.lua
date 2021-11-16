return function(msg, level)
  error(
    string.format(
      "%s[ERROR]%s: %s%s",
      "\27[1;4;31m",
      "\27[0;31m",
      msg,
      "\27[0m"
    ),
    level
  )
end
