package harborview.nordnet.repository;

import harborview.nordnet.downloader.Downloader;
import harborview.nordnet.downloader.PageInfo;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component("adapter.filesystem")
public class NordnetAdapterV1FileSystem extends NordnetAdapterV1 {

    public NordnetAdapterV1FileSystem(@Qualifier("filesystem") Downloader<PageInfo> downloader) {
        super(downloader);
    }

}
