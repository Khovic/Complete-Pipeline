import com.example.Application;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.sql.Connection;

import static org.junit.Assert.assertEquals;

@Component
public class AppTest {

    @Autowired
    Connection connection;

    @Test
    public void testAppOne() {
        Application myapp = new Application(connection);
        String result = myapp.getStatus();
        assertEquals("OK", result);
    }

}
