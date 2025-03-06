package harborview.api.response;

import com.fasterxml.jackson.annotation.JsonGetter;

public record DefaultResponse(@JsonGetter("appStatusCode") AppStatusCode appStatusCode,
                              @JsonGetter("msg") String msg) {
}
