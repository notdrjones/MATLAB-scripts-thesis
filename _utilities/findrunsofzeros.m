function [runs] = findrunsofzeros(check1, check2, minTrackLength)

runs = [];
runstart = 0;
for i =1:height(check1)
    if runstart == 0
        if check1(i)==0 && check2(i)==0
            runstart = i;
        end
    else
        if check1(i)==0 && check2(i)==0
            runend = i;
        else
            if (runend - runstart) > minTrackLength
                currrun = [runstart runend];
                runs = vertcat(runs, currrun);
            end
            runstart = 0;
        end
    end

end