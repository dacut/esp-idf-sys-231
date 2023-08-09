use {esp_idf_sys::vTaskDelay, std::thread::spawn};

fn hello() {
    loop {
        println!("Hello from main.rs!");
        unsafe { vTaskDelay(5000) };
    }
}

fn main() {
    spawn(hello);
}
