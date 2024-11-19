package sample.actuator.dto;

import java.util.Map; // java.util version 6.x
import java.util.Collections;
import java.util.Objects;

/**
 * Data Transfer Object (DTO) for encapsulating information endpoint response data.
 * 
 * Requirements Addressed:
 * - Actuator Info Endpoint Response: Provides structured response format for the /actuator/info 
 *   endpoint data, allowing consistent information representation across the application
 */
public class InfoResponse {
    
    /**
     * Map containing info endpoint data with string keys and object values.
     * Private to ensure encapsulation and controlled access through getter/setter.
     */
    private Map<String, Object> infoData;
    
    /**
     * Constructs a new InfoResponse with the specified info data map.
     *
     * @param infoData Map containing info endpoint data
     * @throws NullPointerException if infoData is null
     */
    public InfoResponse(Map<String, Object> infoData) {
        this.setInfoData(infoData);
    }
    
    /**
     * Retrieves the info data map containing endpoint information.
     * Returns an unmodifiable view of the map to preserve encapsulation.
     *
     * @return Immutable map containing info endpoint data
     */
    public Map<String, Object> getInfoData() {
        return Collections.unmodifiableMap(infoData);
    }
    
    /**
     * Sets the info data map with new endpoint information.
     *
     * @param infoData Map containing new info endpoint data
     * @throws NullPointerException if infoData is null
     */
    public void setInfoData(Map<String, Object> infoData) {
        this.infoData = Objects.requireNonNull(infoData, "Info data map cannot be null");
    }
    
    /**
     * Generates a hash code for this InfoResponse instance.
     *
     * @return hash code value for this object
     */
    @Override
    public int hashCode() {
        return Objects.hash(infoData);
    }
    
    /**
     * Indicates whether some other object is "equal to" this one.
     *
     * @param obj the reference object with which to compare
     * @return true if this object is the same as the obj argument; false otherwise
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        InfoResponse other = (InfoResponse) obj;
        return Objects.equals(infoData, other.infoData);
    }
    
    /**
     * Returns a string representation of this InfoResponse.
     *
     * @return a string representation of this object
     */
    @Override
    public String toString() {
        return "InfoResponse{" +
               "infoData=" + infoData +
               '}';
    }
}