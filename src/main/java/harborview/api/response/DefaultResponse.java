package harborview.api.response;

import com.fasterxml.jackson.annotation.JsonGetter;

public record DefaultResponse(@JsonGetter("appStatusCode") int appStatusCode,
                              @JsonGetter("msg") String msg) {
}
