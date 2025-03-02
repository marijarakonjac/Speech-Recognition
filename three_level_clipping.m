function y_clipped = three_level_clipping(y,cl)
y_clipped = zeros(size(y));
    for i = 1:length(y)
        if y(i) > cl
            y_clipped(i) = 1;
        elseif y(i) < -cl
            y_clipped(i) = -1;
        else
            y_clipped(i) = 0;
        end
    end
end

