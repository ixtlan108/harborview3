package harborview.nordnet.downloader;

import java.net.URL;

public class DownloadException extends RuntimeException {
    private final int httpStatus;
    private final URL url;

    public DownloadException(URL url, int httpStatus) {
        super();

        this.url = url;
        this.httpStatus = httpStatus;

    }

    public int getHttpStatus() {
        return httpStatus;
    }

    public URL getUrl() {
        return url;
    }
}
