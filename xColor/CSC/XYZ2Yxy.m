function Img2 = XYZ2Yxy(Img)
    %YXY2XYZ converts XYZ to Yxy

    [Img,meta] = img2raw(Img);

    % Apply Conversion
    Img2(:,1) = Img(:,2);
    Img2(:,2) = Img(:,1)./(Img(:,1)+Img(:,2)+Img(:,3));
    Img2(:,3) = Img(:,2)./(Img(:,1)+Img(:,2)+Img(:,3));

    % find out when Y from Yxy is ZERO and set XYZ to ZERO
    Img2(repmat(((Img(:,1)+Img(:,2)+Img(:,3)) == 0),[1 3])) = 0;

    Img2 = raw2img(Img2,meta);

end