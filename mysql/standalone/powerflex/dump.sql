SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;--
CREATE TABLE `car` (
`id` int(11) NOT NULL,
`type` text NOT NULL,
`country` text NOT NULL,
`manufacturer` text NOT NULL,
`create_date` date NOT NULL,
`model` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO `car` (`id`, `type`, `country`, `manufacturer`, `create_date`, `model`) VALUES
(1, 'Small', 'Japon', 'Acura', '1931-02-01', 'Integra'),
(2, 'Midsize', 'Japon', 'Acura', '1959-07-30', 'Legend'),
(3, 'Compact', 'Germany', 'Audi', '1970-07-30', '90'),
(4, 'Midsize', 'Germany', 'Audi', '1963-10-04', '100'),
(5, 'Midsize', 'Germany', 'BMW', '1931-09-08', '535i'),
(6, 'Midsize', 'USA', 'Buick', '1957-02-20', 'Century'),
(7, 'Large', 'USA', 'Buick', '1968-10-23', 'LeSabre'),
(8, 'Large', 'USA', 'Buick', '1970-08-17', 'Roadmaster'),
(9, 'Midsize', 'USA', 'Buick', '1962-08-02', 'Riviera'),
(10, 'Large', 'USA', 'Cadillac', '1956-12-01', 'DeVille'),
(11, 'Midsize', 'USA', 'Cadillac', '1957-07-30', 'Seville'),
(12, 'Compact', 'USA', 'Chevrolet', '1952-06-18', 'Cavalier'),
(13, 'Compact', 'USA', 'Chevrolet', '1947-06-26', 'Corsica'),
(14, 'Sporty', 'USA', 'Chevrolet', '1940-05-27', 'Camaro'),
(15, 'Midsize', 'USA', 'Chevrolet', '1949-02-21', 'Lumina'),
(16, 'Van', 'USA', 'Chevrolet', '1944-11-02', 'Lumina_APV'),
(17, 'Van', 'USA', 'Chevrolet', '1962-06-07', 'Astro'),
(18, 'Large', 'USA', 'Chevrolet', '1951-01-11', 'Caprice'),
(19, 'Sporty', 'USA', 'Chevrolet', '1966-11-01', 'Corvette'),
(20, 'Large', 'USA', 'Chrysler', '1964-07-10', 'Concorde'),
(21, 'Compact', 'USA', 'Chrysler', '1938-05-06', 'LeBaron'),
(22, 'Large', 'USA', 'Chrysler', '1960-07-07', 'Imperial'),
(23, 'Small', 'USA', 'Dodge', '1943-06-02', 'Colt'),
(24, 'Small', 'USA', 'Dodge', '1934-02-27', 'Shadow'),
(25, 'Compact', 'USA', 'Dodge', '1932-02-26', 'Spirit'),
(26, 'Van', 'USA', 'Dodge', '1946-06-12', 'Caravan'),
(27, 'Midsize', 'USA', 'Dodge', '1928-03-02', 'Dynasty'),
(28, 'Sporty', 'USA', 'Dodge', '1966-05-20', 'Stealth'),
(29, 'Small', 'USA', 'Eagle', '1941-05-12', 'Summit'),
(30, 'Large', 'USA', 'Eagle', '1963-09-17', 'Vision'),
(31, 'Small', 'USA', 'Ford', '1964-10-22', 'Festiva'),
(32, 'Small', 'USA', 'Ford', '1930-12-02', 'Escort'),
(33, 'Compact', 'USA', 'Ford', '1950-04-19', 'Tempo'),
(34, 'Sporty', 'USA', 'Ford', '1940-06-18', 'Mustang'),
(35, 'Sporty', 'USA', 'Ford', '1941-05-24', 'Probe'),
(36, 'Van', 'USA', 'Ford', '1935-01-27', 'Aerostar'),
(37, 'Midsize', 'USA', 'Ford', '1947-10-08', 'Taurus'),
(38, 'Large', 'USA', 'Ford', '1962-02-28', 'Crown_Victoria'),
(39, 'Small', 'USA', 'Geo', '1965-10-30', 'Metro'),
(40, 'Sporty', 'USA', 'Geo', '1955-07-07', 'Storm'),
(41, 'Sporty', 'Japon', 'Honda', '1955-06-08', 'Prelude'),
(42, 'Small', 'Japon', 'Honda', '1967-09-16', 'Civic'),
(43, 'Compact', 'Japon', 'Honda', '1938-06-26', 'Accord'),
(44, 'Small', 'South Korea', 'Hyundai', '1940-02-25', 'Excel');
ALTER TABLE `car`
ADD PRIMARY KEY (`id`);
ALTER TABLE `car`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;
COMMIT;/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
