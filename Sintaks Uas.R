#========================================================
# MEMANGGIL PACKAGE
#========================================================
library(readxl)
library(psych)

#========================================================
# MEMBACA DATA EXCEL
#========================================================
data <- read_excel("C:/Users/Lina/OneDrive/Dokumen/Matkul Teksam/DATA ESTIMASI RATA - RATA STRATEGI BELAJAR.xlsx")

View(data)

# Melihat struktur data
str(data)
head(data)

#========================================================
# MENGAMBIL ITEM KUESIONER
#========================================================
kuesioner <- data[, c("P1","P2","P3","P4","P5",
                      "P6","P7","P8","P9","P10")]

#========================================================
# MENGHITUNG SKOR TOTAL
#========================================================
data$Total <- rowSums(kuesioner)

# Melihat skor total
head(data)

#========================================================
# CLEANING DATA
#========================================================

# Mengecek data yang hilang
colSums(is.na(data))

# Mengecek outlier skor total dengan visualisasi boxplot
boxplot(data$Total,
        main = "Boxplot Skor Total",
        ylab = "Skor Total")

#========================================================
# UJI VALIDITAS
#========================================================
hasil_validitas <- data.frame(
  Item = names(kuesioner),
  r_hitung = sapply(kuesioner, function(x) cor(x, data$Total)),
  p_value = sapply(kuesioner, function(x) cor.test(x, data$Total)$p.value)
)

hasil_validitas

#========================================================
# UJI RELIABILITAS
#========================================================

hasil_alpha <- alpha(kuesioner)

hasil_alpha$total

#========================================================
# PEMBOBOTAN TWO-STAGE CLUSTER SAMPLING
#========================================================

#-------------------------------
# Tahap 1 : Probabilitas Memilih Cluster
#-------------------------------

N_cluster <- 6      # Jumlah seluruh kelas
n_cluster <- 2      # Jumlah kelas yang dipilih

p1 <- n_cluster / N_cluster

#-------------------------------
# Tahap 2 : Probabilitas Memilih Mahasiswa
#-------------------------------

# Kelas 2024 A
N_2024A <- 25
n_2024A <- 13

p2_2024A <- n_2024A / N_2024A

# Kelas 2025 B
N_2025B <- 31
n_2025B <- 17

p2_2025B <- n_2025B / N_2025B

#-------------------------------
# Probabilitas Gabungan
#-------------------------------

p_total_2024A <- p1 * p2_2024A
p_total_2025B <- p1 * p2_2025B

#-------------------------------
# Bobot Dasar
#-------------------------------

w_2024A <- 1 / p_total_2024A
w_2025B <- 1 / p_total_2025B

# Menampilkan bobot
w_2024A
w_2025B

#-------------------------------
# Memberikan Bobot ke Setiap Responden
#-------------------------------

data$Bobot <- ifelse(data$Angkatan == 2024 & data$Kelas == "A",
                     w_2024A,
                     w_2025B)

# Memastikan bobot sudah benar
table(data$Angkatan, data$Kelas, data$Bobot)

# Melihat tabel
View(data)

#========================================================
# ESTIMASI TITIK (WEIGHTED POINT ESTIMATE)
#========================================================

Estimasi_Titik <- sum(data$Bobot * data$Total)

Estimasi_Titik

#========================================================
# ESTIMASI RATA-RATA
#========================================================

Estimasi_Rata2 <- sum(data$Bobot * data$Total) /
  sum(data$Bobot)

Estimasi_Rata2

#========================================================
# ANALISIS SURVEI
#========================================================

library(survey)

#========================================================
# MEMBUAT VARIABEL CLUSTER
#========================================================

data$Cluster <- paste(data$Angkatan, data$Kelas, sep = "_")

#========================================================
# MEMBENTUK DESAIN SURVEI
#========================================================

desain <- svydesign(
  id = ~Cluster,
  weights = ~Bobot,
  data = data
)

View(data)
#========================================================
# ESTIMASI RATA-RATA
#========================================================

estimasi_mean <- svymean(~Total, desain)

estimasi_mean

#========================================================
# VARIANS ESTIMASI
#========================================================

varians <- vcov(estimasi_mean)

varians

#========================================================
# STANDARD ERROR
#========================================================

standard_error <- SE(estimasi_mean)

standard_error

#========================================================
# CONFIDENCE INTERVAL 95%
#========================================================

confidence_interval <- confint(estimasi_mean)

confidence_interval

#========================================================
# RELATIVE STANDARD ERROR (RSE)
#========================================================

RSE <- (SE(estimasi_mean) / coef(estimasi_mean)) * 100

RSE

#========================================================
# DESIGN EFFECT (DEFF)
#========================================================

estimasi_mean_deff <- svymean(~Total, desain, deff = TRUE)

deff(estimasi_mean_deff)

#========================================================
# VISUALISASI RATA-RATA SETIAP INDIKATOR
#========================================================

# Menghitung rata-rata tiap indikator
rata_indikator <- colMeans(kuesioner)

# Membuat diagram batang
bp <- barplot(
  rata_indikator,
  main = "Rata-rata Skor Setiap Indikator Strategi Belajar",
  xlab = "Indikator",
  ylab = "Rata-rata Skor",
  ylim = c(0, 4.2),
  names.arg = names(rata_indikator),
  col = "lightblue",
  border = "black"
)

# Menambahkan nilai rata-rata di atas batang
text(
  x = bp,
  y = rata_indikator + 0.08,
  labels = round(rata_indikator, 2),
  cex = 0.9
)
