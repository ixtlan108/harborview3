package harborview.nordnet.repository;

import harborview.nordnet.downloader.Downloader;
import harborview.nordnet.downloader.PageInfo;

import java.time.LocalDate;

public class NordnetAdapterBase {

    protected final Downloader<PageInfo> downloader;

    public NordnetAdapterBase(Downloader<PageInfo> downloader) {
        this.downloader = downloader;
    }

    public Downloader<PageInfo> getDownloader() {
        return downloader;
    }

    protected LocalDate getDateFor(String curDate, String curDateTest) {
        if (curDate == null) {
            if (curDateTest == null) {
                return LocalDate.now();
            }
            else {
                return LocalDate.parse(curDateTest);
            }
        }
        else {
            if (curDate.equals("today")) {
                return LocalDate.now();
            }
            else {
                return LocalDate.parse(curDate);
            }
        }
    }
}
