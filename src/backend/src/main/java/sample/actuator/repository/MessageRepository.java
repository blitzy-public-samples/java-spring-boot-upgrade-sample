package sample.actuator.repository;

// Spring Data JPA v3.0.0
import org.springframework.data.jpa.repository.JpaRepository;
// Spring Framework v6.0.0
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import sample.actuator.model.Message;
import java.util.List;

/**
 * Repository interface for Message entity providing CRUD operations and custom queries.
 * 
 * Addresses requirement: Message Persistence
 * Location: Technical Specification/SampleController/POST Endpoint
 * - Provides data access layer for persisting and retrieving Message entities
 * - Implements custom query methods with support for filtering and pagination
 * - Extends JpaRepository to inherit standard CRUD operations
 */
@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    
    /**
     * Finds messages by their value content using Spring Data JPA query derivation.
     * 
     * @param value The message value to search for
     * @return List of messages matching the value, empty list if none found
     * @throws IllegalArgumentException if value parameter is null
     */
    List<Message> findByValue(String value);
    
    /**
     * Retrieves the most recent messages ordered by creation timestamp.
     * Uses a custom JPQL query to fetch latest messages with limit.
     * 
     * @param limit Maximum number of messages to retrieve
     * @return List of most recent messages limited by parameter, ordered by newest first
     * @throws IllegalArgumentException if limit parameter is not positive
     */
    @Query("SELECT m FROM Message m ORDER BY m.id DESC")
    List<Message> findLatestMessages(@Param("limit") int limit);
}