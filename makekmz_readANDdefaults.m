destdir=pwd();    % default output in current directory
imname='default'; % default output file name
clear iscale;     % default auto scaling
clear cmap        % default use grayscale 
forcegray=0;      % default do not force grayscale
clear fignum      % default do not create matlab figure window
RotAngle=0;       % default no rotation
RotLatLon=1;      % default northing/easting rotation
clear alphaa;     % default no alpha channel
clear segment     % default always unsegmented
segment=1;        % default segmented if larger than maxsize
maxsize=1024;     % maximum image segment size recommended by Google Earth
clear timecode    % default no time code
clear background  % default transparent/black background
debugflag=0;      % default no debug output
quiet=1;          % default show status
nplacemarks=0;    % default no placemarks
placemarkname=[]; 
placemarkloc=[];
comment=' ';      % default no comments added
nameprefix=[];    % default no prefix for image title


% decode optional arguments
% note: not checking of the validity of the argument values is done!
narg=length(varargin);
if narg>1
  k=1;
  while k<= narg
    str=char(varargin(k));
    switch str
     case 'alpha'
      k=k+1;
      if k<=narg
        alphaa=cell2mat(varargin(k));
      end
      if size(img)~=size(alphaa)
	disp('*** alpha array size does not match image array size, ignoring');
	clear alphaa
      end
     case 'RotAngle'
      RotAngle=1;
     case 'RotLatLon'
      k=k+1;
      if k<=narg
        RotLatLon=cell2mat(varargin(k));
      end      
     case 'imname'
      k=k+1;
      if k<=narg
        imname=char(varargin(k));
      end
     case 'cmap'
      k=k+1;
      if k<=narg
        cmap=cell2mat(varargin(k));
      end
     case 'forcegray'
      forcegray=1;
     case 'scale'
      k=k+1;
      if k<=narg
        iscale=cell2mat(varargin(k));
      end
     case 'destdir'
      k=k+1;
      if k<=narg
        destdir=char(varargin(k));
      end
     case 'fignum'
      k=k+1;
      if k<=narg
        fignum=cell2mat(varargin(k));
      end
     case 'placemark'
      k=k+1;
      nplacemarks=nplacemarks+1;
      if k<=narg
        placemarkname(nplacemarks,1:length(char(varargin(k))))=char(varargin(k));
      else
        placemarkname(nplacemarks+1,1:7)='unnamed';
      end
      k=k+1;
      if k<=narg
        tmpstr=cell2mat(varargin(k));
        if length(tmpstr)<3
          tmpstr(3)=0;
        end
        placemarkloc(nplacemarks,1:3)=tmpstr(1:3);
      else
        placemarkloc(nplacemarks,1:3)=[0 0 0];
      end
     case 'timecode'
      k=k+1;
      if k<=narg
        timecode=cell2mat(varargin(k));
      end
      if length(timecode)~=6
	disp('*** timecode needs 6 entries in genkmzRs2, ignored');
	clear timecode
      end
     case 'segment'
      segment=1;
     case 'nosegment'
      clear segment
     case 'maxsize'
      k=k+1;
      if k<=narg
       maxsize=cell2mat(varargin(k));
       if maxsize<10 | maxsize > 20000
	 maxsize=1024;
       end
       end
     case 'background'
      k=k+1;
      if k<=narg
        background=cell2mat(varargin(k));
      end
     case 'copyright'
      k=k+1;
      if k<=narg
        copyrightowner=char(varargin(k));
      end
     case 'comment'
      k=k+1;
      if k<=narg
        comment=char(varargin(k));
      end
     case 'nameprefix'
      k=k+1;
      if k<=narg
        nameprefix=char(varargin(k));
      end
     case 'workdir'
      k=k+1;
      if k<=narg
        tmp=char(varargin(k));
      end
     case 'quiet'
      quiet=0;
     case 'debug'
      debugflag=1;
    end
    k=k+1;
  end
end

if filesep()=='/'
  tmp='/tmp';     % default temporary work directory (linux)
else
  tmp=pwd();      % default temporary work directory (non-linux)
end