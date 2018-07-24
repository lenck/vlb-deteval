function [ str ] = seconds2time( secs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[h, m, s] = hms(seconds(secs));
if secs > 60
  if secs > 3600
    str = sprintf('%dh %d''%.0f''''', h, m, s);
  else
    str = sprintf('%d''%.0f''''', m, s);
  end
else
  str = sprintf('%.2f''''', s);
end

end

